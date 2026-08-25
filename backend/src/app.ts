import cors from "cors";
import express from "express";
import multer from "multer";
import { put } from "@vercel/blob";
import nodemailer from "nodemailer";
import { cert, getApps, initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getMessaging } from "firebase-admin/messaging";
import {
  PrismaClientInitializationError,
  PrismaClientKnownRequestError
} from "@prisma/client/runtime/library";
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import { z } from "zod";
import { env } from "./env.js";
import { prisma } from "./prisma.js";
import { requireAdmin, requireAuth } from "./middleware/auth.js";
import {
  createRefreshToken,
  getTokenPair,
  hashPassword,
  hashRefreshToken,
  tokenExpiry,
  verifyPassword
} from "./utils/auth.js";

const app = express();
const db = prisma as any;

const corsOrigins = env.CORS_ORIGIN?.split(",").map((origin) => origin.trim()).filter(Boolean);
const uploadDir = path.resolve("storage/uploads");
const imageMimeTypes = new Set(["image/jpeg", "image/png", "image/webp", "image/gif"]);
const mediaMimeTypes = new Set([...imageMimeTypes, "video/mp4", "video/webm", "video/quicktime"]);
const useBlobStorage = Boolean(env.BLOB_READ_WRITE_TOKEN);
const adminRateLimitStore = new Map<string, { count: number; resetAt: number }>();
const adminRateLimitWindowMs = 60_000;
const adminRateLimitMax = 180;

fs.mkdirSync(uploadDir, { recursive: true });

let firebaseReady = false;
try {
  if (env.FIREBASE_SERVICE_ACCOUNT_JSON && !getApps().length) {
    initializeApp({
      credential: cert(JSON.parse(env.FIREBASE_SERVICE_ACCOUNT_JSON))
    });
    firebaseReady = true;
  } else {
    firebaseReady = getApps().length > 0;
  }
} catch (error) {
  firebaseReady = false;
  console.warn("Firebase Admin was not initialized", error);
}

const upload = multer({
  storage: useBlobStorage
    ? multer.memoryStorage()
    : multer.diskStorage({
        destination: (_req, _file, callback) => callback(null, uploadDir),
        filename: (_req, file, callback) => {
          const extension = path.extname(file.originalname).toLowerCase();
          callback(null, `${crypto.randomUUID()}${extension}`);
        }
      }),
  limits: { fileSize: 25 * 1024 * 1024 },
  fileFilter: (_req, file, callback) => {
    callback(null, mediaMimeTypes.has(file.mimetype));
  }
});

app.use(cors({ origin: corsOrigins?.length ? corsOrigins : true }));
app.use(express.json({ limit: "2mb" }));
app.use("/uploads", express.static(uploadDir));

type AsyncHandler = (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => Promise<unknown>;

const asyncHandler =
  (handler: AsyncHandler): express.RequestHandler =>
  (req, res, next) => {
    void handler(req, res, next).catch(next);
  };

const adminRateLimit: express.RequestHandler = (req, res, next) => {
  const now = Date.now();
  const key = adminRateLimitKey(req);
  const current = adminRateLimitStore.get(key);
  const bucket = !current || current.resetAt <= now
    ? { count: 0, resetAt: now + adminRateLimitWindowMs }
    : current;

  bucket.count += 1;
  adminRateLimitStore.set(key, bucket);

  const remaining = Math.max(0, adminRateLimitMax - bucket.count);
  const retryAfter = Math.max(1, Math.ceil((bucket.resetAt - now) / 1000));
  res.setHeader("X-RateLimit-Limit", String(adminRateLimitMax));
  res.setHeader("X-RateLimit-Remaining", String(remaining));
  res.setHeader("X-RateLimit-Reset", String(Math.ceil(bucket.resetAt / 1000)));

  if (bucket.count > adminRateLimitMax) {
    res.setHeader("Retry-After", String(retryAfter));
    return res.status(429).json({
      message: `Too many dashboard requests. Please wait ${retryAfter} seconds and try again.`
    });
  }

  if (adminRateLimitStore.size > 5000) {
    for (const [storeKey, value] of adminRateLimitStore) {
      if (value.resetAt <= now) adminRateLimitStore.delete(storeKey);
    }
  }

  return next();
};

function adminRateLimitKey(req: express.Request) {
  const authHeader = req.header("authorization") ?? "";
  const identity = authHeader || requestIp(req) || "unknown";
  return crypto.createHash("sha256").update(identity).digest("hex");
}

function hashPasswordResetToken(token: string) {
  return crypto.createHash("sha256").update(token).digest("hex");
}

async function sendPasswordResetEmail(email: string, code: string) {
  if (!env.SMTP_ENABLED || !env.SMTP_HOST || !env.SMTP_PORT || !env.SMTP_USER || !env.SMTP_PASS || !env.SMTP_FROM) {
    return {
      sent: false,
      message: "Password reset email is not configured yet. Please contact an administrator to reset your password."
    };
  }

  try {
    const transporter = nodemailer.createTransport({
      host: env.SMTP_HOST,
      port: env.SMTP_PORT,
      secure: env.SMTP_PORT === 465,
      auth: {
        user: env.SMTP_USER,
        pass: env.SMTP_PASS
      }
    });

    await transporter.sendMail({
      from: env.SMTP_FROM,
      to: email,
      subject: "Reset your Tescon password",
      html: passwordResetEmailHtml(code),
      text: `Your Tescon password reset code is ${code}. This code expires in 30 minutes. If you did not request this, ignore this email.`
    });
  } catch (error) {
    console.error("SMTP password reset email failed", error);
    return {
      sent: false,
      message: smtpFailureMessage(error)
    };
  }

  return { sent: true };
}

function smtpFailureMessage(error: unknown) {
  const message = error instanceof Error ? error.message.toLowerCase() : "";
  if (message.includes("authentication") || message.includes("invalid login") || message.includes("535")) {
    return "Password reset email is not configured correctly. Please check the Brevo SMTP login and SMTP key.";
  }
  if (message.includes("sender") || message.includes("from")) {
    return "Password reset sender email is not verified yet. Please verify the sender in Brevo.";
  }

  return "Password reset email could not be sent right now. Please try again shortly.";
}

function passwordResetEmailHtml(code: string) {
  return `
    <div style="font-family: Inter, Arial, sans-serif; background:#f8f6ff; padding:32px;">
      <div style="max-width:520px; margin:0 auto; background:#ffffff; border-radius:20px; padding:28px; color:#222;">
        <h1 style="margin:0 0 8px; font-size:22px;">Reset your Tescon password</h1>
        <p style="margin:0 0 22px; color:#555; line-height:1.5;">Use this code in the Tescon app to set a new password. The code expires in 30 minutes.</p>
        <div style="font-size:32px; letter-spacing:8px; font-weight:800; color:#34368C; background:#efeffc; border-radius:14px; padding:18px 20px; text-align:center;">${code}</div>
        <p style="margin:22px 0 0; color:#777; font-size:13px; line-height:1.5;">If you did not request a password reset, you can safely ignore this email.</p>
      </div>
    </div>
  `;
}

const publishStatusSchema = z.enum(["DRAFT", "PUBLISHED", "ARCHIVED"]);
const userRoleSchema = z.enum(["USER", "ADMIN", "SUPER_ADMIN"]);
const userStatusSchema = z.enum(["PENDING", "ACTIVE", "SUSPENDED"]);
const notificationAudienceSchema = z.enum(["ALL", "MEMBERS", "EXECUTIVES", "ADMINS", "SUPER_ADMINS"]);
const optionalDateSchema = z.preprocess(
  (value) => (value === "" || value === null ? undefined : value),
  z.coerce.date().optional()
);
const optionalUrlSchema = z.preprocess(
  (value) => (value === "" || value === null ? undefined : value),
  z.string().url().optional()
);
const imageReferenceSchema = z
  .string()
  .refine(
    (value) => value.startsWith("/uploads/") || z.string().url().safeParse(value).success,
    "Expected an uploaded image path or a valid URL"
  );
const mediaReferenceSchema = imageReferenceSchema;
const optionalImageReferenceSchema = imageReferenceSchema.nullable().optional();
const optionalMediaReferenceSchema = mediaReferenceSchema.nullable().optional();
const imageReferencesSchema = z.array(imageReferenceSchema).max(10).default([]);
const optionalImageReferencesSchema = z.array(imageReferenceSchema).max(10).optional();

const adminListQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  pageSize: z.coerce.number().int().min(1).max(1000).default(25)
});
const jobApplicationStatusSchema = z.enum([
  "APPLIED",
  "SHORTLISTED",
  "INTERVIEW_SCHEDULED",
  "INTERVIEWED",
  "OFFERED",
  "REJECTED"
]);
const optionalStringSchema = z.preprocess(
  (value) => (value === "" || value === null ? undefined : value),
  z.string().optional()
);

const registerSchema = z.object({
  email: z.string().trim().email("Enter a valid email address").transform((value) => value.toLowerCase()),
  password: z.string().min(8, "Password must be at least 8 characters"),
  fullName: z.string().trim().min(2, "Full name must be at least 2 characters"),
  phone: z.string().optional(),
  institution: z.string().optional()
});

const loginSchema = z.object({
  email: z.string().trim().email("Enter a valid email address").transform((value) => value.toLowerCase()),
  password: z.string().min(1, "Password is required")
});

const requestPasswordResetSchema = z.object({
  email: z.string().trim().email("Enter a valid email address").transform((value) => value.toLowerCase())
});

const resetPasswordSchema = z.object({
  token: z.string().trim().regex(/^\d{6}$/, "Enter the 6 digit reset code"),
  newPassword: z.string().min(8, "Password must be at least 8 characters")
});

const publicUserSelect = {
  id: true,
  email: true,
  fullName: true,
  phone: true,
  institution: true,
  avatarUrl: true,
  bio: true,
  organizationRole: true,
  role: true,
  status: true,
  chapterId: true,
  createdAt: true,
  updatedAt: true
} as const;

const publicMessageInclude = {
  author: { select: publicUserSelect }
} as const;

const publicConversationInclude = {
  participants: {
    include: { user: { select: publicUserSelect } }
  },
  messages: {
    include: publicMessageInclude,
    orderBy: { createdAt: "asc" as const },
    take: 50
  }
} as const;

const publishedOrder = (limit = 20) => ({
  where: { status: "PUBLISHED" as const },
  orderBy: { createdAt: "desc" as const },
  take: limit
});

const adminSchemas = {
  adminUsers: {
    create: z.object({
      email: z.string().email(),
      password: z.string().min(8),
      fullName: z.string().min(2),
      phone: z.string().optional(),
      avatarUrl: optionalImageReferenceSchema,
      bio: z.string().optional(),
      role: z.enum(["ADMIN", "SUPER_ADMIN"]).default("ADMIN"),
      status: userStatusSchema.default("ACTIVE")
    }),
    update: z.object({
      email: z.string().email().optional(),
      password: z.string().min(8).optional(),
      fullName: z.string().min(2).optional(),
      phone: z.string().optional(),
      avatarUrl: optionalImageReferenceSchema,
      bio: z.string().optional(),
      role: z.enum(["ADMIN", "SUPER_ADMIN"]).optional(),
      status: userStatusSchema.optional()
    })
  },
  users: {
    create: z.object({
      email: z.string().email(),
      password: z.string().min(8).optional(),
      fullName: z.string().min(2),
      phone: z.string().optional(),
      institution: z.string().optional(),
      avatarUrl: optionalImageReferenceSchema,
      bio: z.string().optional(),
      organizationRole: z.string().min(2).optional(),
      role: userRoleSchema.default("USER"),
      status: userStatusSchema.default("ACTIVE"),
      chapterId: z.string().optional()
    }),
    update: z.object({
      email: z.string().email().optional(),
      password: z.string().min(8).optional(),
      fullName: z.string().min(2).optional(),
      phone: z.string().optional(),
      institution: z.string().optional(),
      avatarUrl: optionalImageReferenceSchema,
      bio: z.string().optional(),
      organizationRole: z.string().min(2).optional(),
      role: userRoleSchema.optional(),
      status: userStatusSchema.optional(),
      chapterId: z.string().optional()
    })
  },
  chapters: {
    create: z.object({
      name: z.string().min(2),
      campus: z.string().min(2),
      region: z.string().optional(),
      description: z.string().optional(),
      logoUrl: optionalImageReferenceSchema,
      memberEstimate: z.coerce.number().int().min(0).optional()
    }),
    update: z.object({
      name: z.string().min(2).optional(),
      campus: z.string().min(2).optional(),
      region: z.string().optional(),
      description: z.string().optional(),
      logoUrl: optionalImageReferenceSchema,
      memberEstimate: z.coerce.number().int().min(0).optional()
    })
  },
  news: {
    create: z.object({
      title: z.string().min(2),
      summary: z.string().min(2),
      body: z.string().min(2),
      category: z.string().optional(),
      imageUrl: optionalImageReferenceSchema,
      imageUrls: imageReferencesSchema,
      status: publishStatusSchema.default("DRAFT"),
      publishedAt: optionalDateSchema
    }),
    update: z.object({
      title: z.string().min(2).optional(),
      summary: z.string().min(2).optional(),
      body: z.string().min(2).optional(),
      category: z.string().optional(),
      imageUrl: optionalImageReferenceSchema,
      imageUrls: optionalImageReferencesSchema,
      status: publishStatusSchema.optional(),
      publishedAt: optionalDateSchema
    })
  },
  events: {
    create: z.object({
      title: z.string().min(2),
      description: z.string().min(2),
      organizer: z.string().min(2).default("TESCON"),
      venue: z.string().min(2),
      venueNote: z.string().optional(),
      startsAt: z.coerce.date(),
      endsAt: optionalDateSchema,
      feeLabel: z.string().min(2).default("Free"),
      chatUrl: optionalUrlSchema,
      imageUrl: optionalImageReferenceSchema,
      imageUrls: imageReferencesSchema,
      status: publishStatusSchema.default("PUBLISHED"),
      chapterId: z.string().optional()
    }),
    update: z.object({
      title: z.string().min(2).optional(),
      description: z.string().min(2).optional(),
      organizer: z.string().min(2).optional(),
      venue: z.string().min(2).optional(),
      venueNote: z.string().optional(),
      startsAt: z.coerce.date().optional(),
      endsAt: optionalDateSchema,
      feeLabel: z.string().min(2).optional(),
      chatUrl: optionalUrlSchema,
      imageUrl: optionalImageReferenceSchema,
      imageUrls: optionalImageReferencesSchema,
      status: publishStatusSchema.optional(),
      chapterId: z.string().optional()
    })
  },
  announcements: {
    create: z.object({
      title: z.string().min(2),
      body: z.string().min(2),
      priority: z.enum(["normal", "high", "urgent"]).default("normal"),
      status: publishStatusSchema.default("DRAFT"),
      publishedAt: optionalDateSchema
    }),
    update: z.object({
      title: z.string().min(2).optional(),
      body: z.string().min(2).optional(),
      priority: z.enum(["normal", "high", "urgent"]).optional(),
      status: publishStatusSchema.optional(),
      publishedAt: optionalDateSchema
    })
  },
  history: {
    create: z.object({
      title: z.string().min(2),
      summary: z.string().optional(),
      body: z.string().min(2),
      category: z.string().optional(),
      occurredAt: optionalDateSchema,
      imageUrl: optionalImageReferenceSchema,
      mediaUrl: optionalMediaReferenceSchema,
      mediaType: optionalStringSchema,
      status: publishStatusSchema.default("PUBLISHED")
    }),
    update: z.object({
      title: z.string().min(2).optional(),
      summary: z.string().optional(),
      body: z.string().min(2).optional(),
      category: z.string().optional(),
      occurredAt: optionalDateSchema,
      imageUrl: optionalImageReferenceSchema,
      mediaUrl: optionalMediaReferenceSchema,
      mediaType: optionalStringSchema,
      status: publishStatusSchema.optional()
    })
  },
  jobs: {
    create: z.object({
      title: z.string().min(2),
      company: z.string().min(2),
      logoUrl: optionalImageReferenceSchema,
      location: z.string().min(2),
      type: z.string().min(2),
      description: z.string().min(2),
      applyUrl: z.string().url().optional(),
      deadline: optionalDateSchema,
      status: publishStatusSchema.default("DRAFT")
    }),
    update: z.object({
      title: z.string().min(2).optional(),
      company: z.string().min(2).optional(),
      logoUrl: optionalImageReferenceSchema,
      location: z.string().min(2).optional(),
      type: z.string().min(2).optional(),
      description: z.string().min(2).optional(),
      applyUrl: z.string().url().optional(),
      deadline: optionalDateSchema,
      status: publishStatusSchema.optional()
    })
  },
  polls: {
    create: z.object({
      question: z.string().min(2),
      description: z.string().optional(),
      options: z.array(z.string().min(1)).min(2).max(20),
      status: publishStatusSchema.default("PUBLISHED"),
      closesAt: optionalDateSchema,
      visibility: z.string().min(2).default("members"),
      allowMultipleVotes: z.boolean().default(false)
    }),
    update: z.object({
      question: z.string().min(2).optional(),
      description: z.string().optional(),
      options: z.array(z.string().min(1)).min(2).max(20).optional(),
      status: publishStatusSchema.optional(),
      closesAt: optionalDateSchema,
      visibility: z.string().min(2).optional(),
      allowMultipleVotes: z.boolean().optional()
    })
  },
  conversations: {
    create: z.object({ title: z.string().min(2), isGroup: z.boolean().default(true) }),
    update: z.object({ title: z.string().min(2).optional(), isGroup: z.boolean().optional() })
  },
  notifications: {
    create: z.object({
      title: z.string().min(2),
      body: z.string().min(2),
      audience: notificationAudienceSchema.default("ALL"),
      userId: z.string().optional(),
      readAt: optionalDateSchema
    }),
    update: z.object({
      title: z.string().min(2).optional(),
      body: z.string().min(2).optional(),
      audience: notificationAudienceSchema.optional(),
      userId: z.string().optional(),
      readAt: optionalDateSchema
    })
  },
  contacts: {
    create: z.object({
      name: z.string().min(2),
      email: z.string().email(),
      topic: z.string().min(2),
      message: z.string().min(5),
      resolved: z.boolean().default(false)
    }),
    update: z.object({
      name: z.string().min(2).optional(),
      email: z.string().email().optional(),
      topic: z.string().min(2).optional(),
      message: z.string().min(5).optional(),
      resolved: z.boolean().optional()
    })
  },
  jobApplications: {
    create: z.object({
      jobId: z.string().min(1),
      userId: z.string().optional(),
      fullName: z.string().min(2),
      email: z.string().email(),
      phone: z.string().optional(),
      institution: z.string().optional(),
      coverNote: z.string().optional(),
      credentialsUrl: optionalImageReferenceSchema,
      supportingUrl: optionalImageReferenceSchema,
      status: jobApplicationStatusSchema.default("APPLIED"),
      interviewAt: optionalDateSchema,
      interviewNote: z.string().optional()
    }),
    update: z.object({
      fullName: z.string().min(2).optional(),
      email: z.string().email().optional(),
      phone: z.string().optional(),
      institution: z.string().optional(),
      coverNote: z.string().optional(),
      credentialsUrl: optionalImageReferenceSchema,
      supportingUrl: optionalImageReferenceSchema,
      status: jobApplicationStatusSchema.optional(),
      interviewAt: optionalDateSchema,
      interviewNote: z.string().optional()
    })
  }
} as const;

app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "tescon-backend" });
});

app.get("/api/media", asyncHandler(async (req, res) => {
  const rawUrl = z.string().url().parse(req.query.url);
  const mediaUrl = new URL(rawUrl);
  const allowedBlobHost = mediaUrl.hostname.endsWith(".public.blob.vercel-storage.com");

  if (mediaUrl.protocol !== "https:" || !allowedBlobHost) {
    return res.status(400).json({ message: "Unsupported media URL" });
  }

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 12000);
  const response = await fetch(mediaUrl, { signal: controller.signal }).finally(() => clearTimeout(timeout));
  if (!response.ok) {
    return res.status(response.status).json({ message: "Media unavailable" });
  }

  const contentType = response.headers.get("content-type") ?? "application/octet-stream";
  const cacheControl =
    response.headers.get("cache-control") ?? "public, max-age=86400, s-maxage=86400";
  const body = Buffer.from(await response.arrayBuffer());

  res.setHeader("Content-Type", contentType);
  res.setHeader("Cache-Control", cacheControl);
  res.send(body);
}));

app.post("/api/auth/register", asyncHandler(async (req, res) => {
  const body = registerSchema.parse(req.body);
  const { password, ...userData } = body;
  const passwordHash = await hashPassword(body.password);
  const user = await prisma.user.create({
    data: { ...userData, passwordHash, status: "ACTIVE" },
    select: publicUserSelect
  });

  const tokens = await createSession(user);
  res.status(201).json({ user, tokens });
}));

app.post("/api/auth/login", asyncHandler(async (req, res) => {
  const body = loginSchema.parse(req.body);
  const user = await prisma.user.findUnique({ where: { email: body.email } });

  if (!user || !(await verifyPassword(body.password, user.passwordHash))) {
    return res.status(401).json({ message: "Invalid email or password" });
  }

  if (user.status === "SUSPENDED") {
    return res.status(403).json({ message: "This account is suspended" });
  }

  const safeUser = toPublicUser(user);
  const tokens = await createSession(safeUser);
  return res.json({ user: safeUser, tokens });
}));

app.post("/api/auth/request-password-reset", asyncHandler(async (req, res) => {
  const body = requestPasswordResetSchema.parse(req.body);
  const user = await prisma.user.findUnique({ where: { email: body.email } });
  const resetCode = crypto.randomInt(100000, 1000000).toString();
  const emailConfigured = Boolean(
    env.SMTP_ENABLED && env.SMTP_HOST && env.SMTP_PORT && env.SMTP_USER && env.SMTP_PASS && env.SMTP_FROM
  );

  if (user) {
    await db.passwordResetToken.create({
      data: {
        tokenHash: hashPasswordResetToken(resetCode),
        userId: user.id,
        expiresAt: tokenExpiry(30 * 60)
      }
    });
  }

  if (!emailConfigured) {
    return res.status(503).json({
      message: "Password reset email is not configured yet. Please contact an administrator to reset your password."
    });
  }

  if (user) {
    const delivery = await sendPasswordResetEmail(body.email, resetCode);
    if (!delivery.sent) {
      return res.status(503).json({
        message: delivery.message
      });
    }
  }

  return res.json({
    message: "If an account exists for this email, a reset code has been sent."
  });
}));

app.post("/api/auth/reset-password", asyncHandler(async (req, res) => {
  const body = resetPasswordSchema.parse(req.body);
  const reset = await db.passwordResetToken.findUnique({
    where: { tokenHash: hashPasswordResetToken(body.token) },
    include: { user: true }
  });

  if (!reset || reset.usedAt || reset.expiresAt <= new Date()) {
    return res.status(400).json({ message: "This password reset link is invalid or has expired." });
  }

  if (reset.user.status === "SUSPENDED") {
    return res.status(403).json({ message: "This account is suspended." });
  }

  await prisma.$transaction([
    prisma.user.update({
      where: { id: reset.userId },
      data: { passwordHash: await hashPassword(body.newPassword), status: "ACTIVE" }
    }),
    db.passwordResetToken.update({
      where: { id: reset.id },
      data: { usedAt: new Date() }
    }),
    prisma.refreshToken.updateMany({
      where: { userId: reset.userId, revokedAt: null },
      data: { revokedAt: new Date() }
    })
  ]);

  return res.status(204).send();
}));

app.post("/api/auth/firebase", asyncHandler(async (req, res) => {
  if (!firebaseReady) {
    return res.status(503).json({ message: "Firebase authentication is not configured" });
  }

  const body = z.object({ idToken: z.string().min(10) }).parse(req.body);
  const decoded = await getAuth().verifyIdToken(body.idToken);
  if (!decoded.email) {
    return res.status(400).json({ message: "Firebase account has no email address" });
  }

  const fullName =
    typeof decoded.name === "string" && decoded.name.trim()
      ? decoded.name.trim()
      : decoded.email.split("@")[0];
  const avatarUrl = typeof decoded.picture === "string" ? decoded.picture : undefined;

  const user = await prisma.user.upsert({
    where: { email: decoded.email },
    update: {
      fullName,
      avatarUrl,
      status: "ACTIVE"
    },
    create: {
      email: decoded.email,
      fullName,
      avatarUrl,
      status: "ACTIVE",
      passwordHash: await hashPassword(createRefreshToken())
    },
    select: publicUserSelect
  });

  const tokens = await createSession(user);
  return res.json({ user, tokens });
}));

app.post("/api/auth/refresh", asyncHandler(async (req, res) => {
  const body = z.object({ refreshToken: z.string().min(1) }).parse(req.body);
  const tokenHash = hashRefreshToken(body.refreshToken);
  const session = await prisma.refreshToken.findUnique({
    where: { tokenHash },
    include: { user: true }
  });

  if (!session || session.revokedAt || session.expiresAt <= new Date()) {
    return res.status(401).json({ message: "Invalid refresh token" });
  }

  if (session.user.status === "SUSPENDED") {
    return res.status(403).json({ message: "This account is suspended" });
  }

  await prisma.refreshToken.update({
    where: { id: session.id },
    data: { revokedAt: new Date() }
  });

  const user = toPublicUser(session.user);
  const tokens = await createSession(user);
  return res.json({ user, tokens });
}));

app.post("/api/auth/logout", requireAuth, asyncHandler(async (req, res) => {
  const body = z.object({ refreshToken: z.string().optional() }).parse(req.body);

  if (body.refreshToken) {
    await prisma.refreshToken.updateMany({
      where: {
        tokenHash: hashRefreshToken(body.refreshToken),
        userId: req.user!.id,
        revokedAt: null
      },
      data: { revokedAt: new Date() }
    });
  }

  res.status(204).send();
}));

app.get("/api/auth/me", requireAuth, asyncHandler(async (req, res) => {
  const user = await prisma.user.findUnique({
    where: { id: req.user!.id },
    select: publicUserSelect
  });
  res.json({ user });
}));

app.post("/api/auth/change-password", requireAuth, asyncHandler(async (req, res) => {
  const body = z.object({
    currentPassword: z.string().min(1),
    newPassword: z.string().min(8)
  }).parse(req.body);

  const user = await prisma.user.findUnique({ where: { id: req.user!.id } });
  if (!user || !(await verifyPassword(body.currentPassword, user.passwordHash))) {
    return res.status(401).json({ message: "Current password is incorrect" });
  }

  await prisma.$transaction([
    prisma.user.update({
      where: { id: req.user!.id },
      data: { passwordHash: await hashPassword(body.newPassword) }
    }),
    prisma.refreshToken.updateMany({
      where: { userId: req.user!.id, revokedAt: null },
      data: { revokedAt: new Date() }
    })
  ]);

  res.status(204).send();
}));

app.get("/api/app/bootstrap", asyncHandler(async (_req, res) => {
  const [news, events, announcements, history, jobs, rawChapters, polls] = await Promise.all([
    prisma.newsArticle.findMany(publishedOrder()),
    prisma.event.findMany(publishedOrder()),
    prisma.announcement.findMany(publishedOrder()),
    db.historyEntry.findMany(publishedOrder()),
    prisma.job.findMany(publishedOrder()),
    prisma.chapter.findMany({
      include: {
        _count: { select: { members: true, events: true } },
        members: {
          where: { status: "ACTIVE", organizationRole: { not: null } },
          select: { id: true }
        }
      },
      orderBy: { name: "asc" }
    }),
    prisma.poll.findMany({
      where: { status: "PUBLISHED" },
      include: { options: { include: { _count: { select: { votes: true } } } } },
      orderBy: { createdAt: "desc" },
      take: 20
    })
  ]);
  const chapters = rawChapters.map(({ _count, members, ...chapter }) => ({
    ...chapter,
    membersCount: (chapter as any).memberEstimate ?? _count.members,
    executivesCount: members.length,
    eventsCount: _count.events
  }));

  res.json({ news, events, announcements, history, jobs, chapters, polls });
}));

app.get("/api/app/history", asyncHandler(async (_req, res) => {
  const history = await db.historyEntry.findMany({
    where: { status: "PUBLISHED" },
    orderBy: [{ occurredAt: "desc" }, { createdAt: "desc" }],
    take: 100
  });
  res.json({ history });
}));

app.post("/api/app/contact", asyncHandler(async (req, res) => {
  const body = z.object({
    name: z.string().min(2),
    email: z.string().email(),
    topic: z.string().min(2),
    message: z.string().min(5)
  }).parse(req.body);

  const contactMessage = await prisma.contactMessage.create({ data: body });
  res.status(201).json({ contactMessage });
}));

app.get("/api/app/members", requireAuth, asyncHandler(async (req, res) => {
  const institution = typeof req.query.institution === "string" ? req.query.institution.trim() : "";
  const members = await prisma.user.findMany({
    where: {
      status: "ACTIVE",
      role: "USER",
      ...(institution ? { institution } : {})
    },
    select: publicUserSelect,
    orderBy: { fullName: "asc" },
    take: 200
  });
  res.json({ members });
}));

app.get("/api/app/executives", requireAuth, asyncHandler(async (req, res) => {
  const institution = typeof req.query.institution === "string" ? req.query.institution.trim() : "";
  const executives = await prisma.user.findMany({
    where: {
      status: "ACTIVE",
      role: "USER",
      organizationRole: { not: null },
      ...(institution ? { institution } : {})
    },
    select: publicUserSelect,
    orderBy: { fullName: "asc" },
    take: 200
  });
  res.json({ executives });
}));

app.patch("/api/app/profile", requireAuth, asyncHandler(async (req, res) => {
  const body = z.object({
    fullName: z.string().min(2).optional(),
    phone: z.string().optional(),
    institution: z.string().optional(),
    avatarUrl: optionalImageReferenceSchema,
    bio: z.string().optional()
  }).parse(req.body);

  const user = await prisma.user.update({
    where: { id: req.user!.id },
    data: body,
    select: publicUserSelect
  });
  res.json({ user });
}));

app.get("/api/app/notifications", requireAuth, asyncHandler(async (req, res) => {
  const user = await prisma.user.findUnique({
    where: { id: req.user!.id },
    select: { role: true, organizationRole: true }
  });
  const audiences = notificationAudiencesForUser(user);
  const notifications = await (prisma.notification as any).findMany({
    where: {
      OR: [
        { userId: req.user!.id },
        {
          userId: null,
          audience: { in: audiences }
        }
      ]
    },
    orderBy: { createdAt: "desc" },
    take: 100
  });
  res.json({ notifications });
}));

app.patch("/api/app/notifications/:id/read", requireAuth, asyncHandler(async (req, res) => {
  const id = String(req.params.id);
  const notification = await prisma.notification.update({
    where: { id },
    data: { readAt: new Date() }
  });
  res.json({ notification });
}));

app.post("/api/app/device-tokens", requireAuth, asyncHandler(async (req, res) => {
  const body = z.object({
    token: z.string().min(10),
    platform: z.string().optional(),
    enabled: z.boolean().default(true)
  }).parse(req.body);

  const deviceToken = await db.deviceToken.upsert({
    where: { token: body.token },
    update: {
      userId: req.user!.id,
      platform: body.platform,
      enabled: body.enabled,
      lastSeenAt: new Date()
    },
    create: {
      token: body.token,
      platform: body.platform,
      enabled: body.enabled,
      userId: req.user!.id
    }
  });

  res.status(201).json({ deviceToken });
}));

app.delete("/api/app/device-tokens", requireAuth, asyncHandler(async (req, res) => {
  const body = z.object({ token: z.string().min(10) }).parse(req.body);
  await db.deviceToken.updateMany({
    where: { token: body.token, userId: req.user!.id },
    data: { enabled: false }
  });
  res.status(204).send();
}));

app.post("/api/app/device-tokens/disable", requireAuth, asyncHandler(async (req, res) => {
  const body = z.object({ token: z.string().min(10) }).parse(req.body);
  await db.deviceToken.updateMany({
    where: { token: body.token, userId: req.user!.id },
    data: { enabled: false }
  });
  res.status(204).send();
}));

app.get("/api/app/conversations", requireAuth, asyncHandler(async (req, res) => {
  const conversations = await db.conversation.findMany({
    where: {
      OR: [
        { isGroup: true },
        { creatorId: req.user!.id },
        { participants: { some: { userId: req.user!.id } } }
      ]
    },
    include: publicConversationInclude,
    orderBy: { updatedAt: "desc" },
    take: 100
  });
  res.json({ conversations });
}));

app.post("/api/app/conversations", requireAuth, asyncHandler(async (req, res) => {
  const body = z.object({
    title: z.string().min(2),
    participantIds: z.array(z.string().min(1)).max(50).default([])
  }).parse(req.body);
  const participantIds = Array.from(new Set([req.user!.id, ...body.participantIds]));
  const conversation = await db.conversation.create({
    data: {
      title: body.title,
      isGroup: true,
      creatorId: req.user!.id,
      participants: {
        create: participantIds.map((userId) => ({
          userId,
          role: userId === req.user!.id ? "OWNER" : "MEMBER"
        }))
      }
    },
    include: publicConversationInclude
  });
  res.status(201).json({ conversation });
}));

app.get("/api/app/conversations/:id/messages", requireAuth, asyncHandler(async (req, res) => {
  const id = String(req.params.id);
  const conversation = await db.conversation.findFirst({
    where: {
      id,
      OR: [
        { isGroup: true },
        { creatorId: req.user!.id },
        { participants: { some: { userId: req.user!.id } } }
      ]
    },
    select: { id: true }
  });
  if (!conversation) return res.status(404).json({ message: "Conversation not found" });

  const messages = await db.message.findMany({
    where: { conversationId: id },
    include: publicMessageInclude,
    orderBy: { createdAt: "asc" },
    take: 100
  });
  res.json({ messages });
}));

app.post("/api/app/conversations/:id/messages", requireAuth, asyncHandler(async (req, res) => {
  const id = String(req.params.id);
  const body = z.object({
    body: z.string().max(1000).default(""),
    mediaUrl: optionalImageReferenceSchema,
    mediaType: optionalStringSchema
  }).refine((value) => value.body.trim().length > 0 || Boolean(value.mediaUrl), {
    message: "Message text or media is required"
  }).parse(req.body);
  const conversation = await db.conversation.findFirst({
    where: {
      id,
      OR: [
        { isGroup: true },
        { creatorId: req.user!.id },
        { participants: { some: { userId: req.user!.id } } }
      ]
    },
    select: { id: true }
  });
  if (!conversation) return res.status(404).json({ message: "Conversation not found" });

  await db.conversationParticipant.upsert({
    where: { conversationId_userId: { conversationId: id, userId: req.user!.id } },
    update: {},
    create: { conversationId: id, userId: req.user!.id }
  });

  const message = await db.message.create({
    data: {
      body: body.body,
      mediaUrl: body.mediaUrl ?? undefined,
      mediaType: body.mediaType ?? undefined,
      conversationId: id,
      authorId: req.user!.id
    },
    include: publicMessageInclude
  });
  await db.conversation.update({
    where: { id },
    data: { updatedAt: new Date() }
  });
  res.status(201).json({ message });
}));

app.post("/api/app/conversations/:id/participants", requireAuth, asyncHandler(async (req, res) => {
  const id = String(req.params.id);
  const body = z.object({ userId: z.string().min(1) }).parse(req.body);
  const conversation = await db.conversation.findFirst({
    where: {
      id,
      OR: [
        { creatorId: req.user!.id },
        { participants: { some: { userId: req.user!.id, role: { in: ["OWNER", "MODERATOR"] } } } }
      ]
    },
    select: { id: true }
  });
  if (!conversation) return res.status(404).json({ message: "Conversation not found" });

  const participant = await db.conversationParticipant.upsert({
    where: { conversationId_userId: { conversationId: id, userId: body.userId } },
    update: {},
    create: { conversationId: id, userId: body.userId }
  });
  res.status(201).json({ participant });
}));

app.post("/api/app/jobs/:id/apply", requireAuth, asyncHandler(async (req, res) => {
  const id = String(req.params.id);
  const currentUser = await prisma.user.findUnique({ where: { id: req.user!.id }, select: publicUserSelect });
  const body = z.object({
    fullName: z.string().min(2).optional(),
    email: z.string().email().optional(),
    phone: z.string().optional(),
    institution: z.string().optional(),
    coverNote: z.string().max(2000).optional(),
    credentialsUrl: optionalImageReferenceSchema,
    supportingUrl: optionalImageReferenceSchema
  }).parse(req.body);
  const job = await prisma.job.findFirst({ where: { id, status: "PUBLISHED" }, select: { id: true } });
  if (!job) return res.status(404).json({ message: "Job not found" });
  if (!currentUser) return res.status(401).json({ message: "Authentication required" });

  const application = await db.jobApplication.upsert({
    where: { jobId_email: { jobId: id, email: body.email ?? currentUser.email } },
    update: {
      phone: body.phone ?? currentUser.phone,
      institution: body.institution ?? currentUser.institution,
      coverNote: body.coverNote,
      credentialsUrl: body.credentialsUrl ?? undefined,
      supportingUrl: body.supportingUrl ?? undefined
    },
    create: {
      jobId: id,
      userId: currentUser.id,
      fullName: body.fullName ?? currentUser.fullName,
      email: body.email ?? currentUser.email,
      phone: body.phone ?? currentUser.phone,
      institution: body.institution ?? currentUser.institution,
      coverNote: body.coverNote,
      credentialsUrl: body.credentialsUrl ?? undefined,
      supportingUrl: body.supportingUrl ?? undefined
    }
  });
  res.status(201).json({ application });
}));

app.post(
  "/api/app/uploads",
  requireAuth,
  upload.single("file"),
  asyncHandler(async (req, res) => {
    if (!req.file) {
      return res.status(400).json({ message: "Media file is required" });
    }

    if (useBlobStorage) {
      const extension = path.extname(req.file.originalname).toLowerCase();
      const filename = `uploads/${crypto.randomUUID()}${extension}`;
      const blob = await put(filename, req.file.buffer, {
        access: "public",
        contentType: req.file.mimetype
      });

      return res.status(201).json({
        url: blob.url,
        filename,
        contentType: req.file.mimetype,
        size: req.file.size
      });
    }

    return res.status(201).json({
      url: `/uploads/${req.file.filename}`,
      filename: req.file.filename,
      contentType: req.file.mimetype,
      size: req.file.size
    });
  })
);

app.get("/api/app/saved-items", requireAuth, asyncHandler(async (req, res) => {
  const savedItems = await prisma.savedItem.findMany({
    where: { userId: req.user!.id },
    orderBy: { createdAt: "desc" }
  });
  res.json({ savedItems });
}));

app.post("/api/app/saved-items", requireAuth, asyncHandler(async (req, res) => {
  const body = z.object({
    itemType: z.enum(["NEWS", "EVENT", "JOB", "ANNOUNCEMENT"]),
    itemId: z.string().min(1)
  }).parse(req.body);

  const savedItem = await prisma.savedItem.upsert({
    where: {
      userId_itemType_itemId: {
        userId: req.user!.id,
        itemType: body.itemType,
        itemId: body.itemId
      }
    },
    update: {},
    create: { ...body, userId: req.user!.id }
  });
  res.status(201).json({ savedItem });
}));

app.delete("/api/app/saved-items/:itemType/:itemId", requireAuth, asyncHandler(async (req, res) => {
  const itemType = z.enum(["NEWS", "EVENT", "JOB", "ANNOUNCEMENT"]).parse(String(req.params.itemType));
  const itemId = String(req.params.itemId);
  await prisma.savedItem.deleteMany({
    where: {
      userId: req.user!.id,
      itemType,
      itemId
    }
  });
  res.status(204).send();
}));

app.post("/api/app/polls/:pollId/vote", requireAuth, asyncHandler(async (req, res) => {
  const pollId = String(req.params.pollId);
  const body = z.object({ optionId: z.string().min(1) }).parse(req.body);
  const poll = await prisma.poll.findFirst({
    where: {
      id: pollId,
      status: "PUBLISHED",
      OR: [{ closesAt: null }, { closesAt: { gt: new Date() } }]
    },
    select: { id: true }
  });

  if (!poll) {
    return res.status(404).json({ message: "Poll not found or closed" });
  }

  const option = await prisma.pollOption.findFirst({
    where: { id: body.optionId, pollId },
    select: { id: true }
  });

  if (!option) {
    return res.status(400).json({ message: "Invalid poll option" });
  }

  const vote = await prisma.pollVote.upsert({
    where: { pollId_userId: { pollId, userId: req.user!.id } },
    update: { optionId: body.optionId },
    create: { pollId, optionId: body.optionId, userId: req.user!.id }
  });

  res.status(201).json({ vote });
}));

const resources = {
  adminUsers: {
    delegate: prisma.user,
    select: publicUserSelect,
    where: { role: { in: ["ADMIN", "SUPER_ADMIN"] } },
    scrubCreate: async (data: any) => ({
      ...data,
      organizationRole: null,
      chapterId: null,
      institution: null,
      passwordHash: await hashPassword(data.password)
    })
  },
  users: {
    delegate: prisma.user,
    select: publicUserSelect,
    scrubCreate: async (data: any) => ({
      ...data,
      passwordHash: await hashPassword(data.password ?? createRefreshToken())
    })
  },
  chapters: { delegate: prisma.chapter },
  news: { delegate: prisma.newsArticle },
  events: { delegate: prisma.event },
  announcements: { delegate: prisma.announcement },
  history: { delegate: db.historyEntry },
  jobs: { delegate: prisma.job },
  jobApplications: {
    delegate: db.jobApplication,
    include: { job: true, user: { select: publicUserSelect } }
  },
  polls: { delegate: prisma.poll, include: { options: { include: { _count: { select: { votes: true } } } } } },
  conversations: { delegate: prisma.conversation, include: publicConversationInclude },
  notifications: { delegate: prisma.notification },
  contacts: { delegate: prisma.contactMessage },
  activityLogs: {
    delegate: db.activityLog,
    include: { actor: { select: publicUserSelect } },
    readOnly: true
  }
} as const;

const ownedResourceNames = new Set(["news", "events", "announcements", "history", "jobs", "polls", "conversations"]);
const executiveWritableResourceNames = new Set([
  "news",
  "events",
  "announcements",
  "history",
  "jobs",
  "jobApplications",
  "polls",
  "conversations"
]);

async function getDashboardUser(req: express.Request) {
  const cached = (req as any).dashboardUser;
  if (cached) return cached as {
    id: string;
    email: string;
    fullName: string;
    role: "USER" | "ADMIN" | "SUPER_ADMIN";
    status: "PENDING" | "ACTIVE" | "SUSPENDED";
    organizationRole: string | null;
  };

  const user = await prisma.user.findUnique({
    where: { id: req.user!.id },
    select: { id: true, email: true, fullName: true, role: true, status: true, organizationRole: true }
  });
  (req as any).dashboardUser = user;
  return user;
}

const isFullAdmin = (user?: { role: string } | null) => Boolean(user && ["ADMIN", "SUPER_ADMIN"].includes(user.role));
const isSuperAdmin = (user?: { role: string } | null) => user?.role === "SUPER_ADMIN";
const canUseDashboard = (user?: { role: string; status: string; organizationRole: string | null } | null) =>
  Boolean(user && user.status === "ACTIVE" && (isFullAdmin(user) || user.organizationRole));
const allDashboardResources = [
  "adminUsers",
  "users",
  "executives",
  "chapters",
  "news",
  "events",
  "announcements",
  "history",
  "jobs",
  "jobApplications",
  "polls",
  "conversations",
  "notifications",
  "contacts",
  "activityLogs"
] as const;
type DashboardResourceName = typeof allDashboardResources[number];
type DashboardPermission = "read" | "create" | "update" | "delete" | "message" | "upload";
type DashboardPermissionMap = Record<DashboardResourceName, DashboardPermission[]>;

function dashboardPermissionsFor(user?: { role: string; organizationRole: string | null } | null): DashboardPermissionMap {
  const empty = emptyDashboardPermissions();
  if (!user) return empty;

  const full = ["read", "create", "update", "delete", "message", "upload"] as DashboardPermission[];
  if (isSuperAdmin(user)) {
    return Object.fromEntries(allDashboardResources.map((resource) => [resource, [...full]])) as DashboardPermissionMap;
  }
  if (user.role === "ADMIN") {
    return {
      ...Object.fromEntries(allDashboardResources.map((resource) => [resource, [...full]])) as DashboardPermissionMap,
      adminUsers: []
    };
  }

  if (!user.organizationRole) return empty;

  return {
    ...empty,
    chapters: ["read"],
    news: ["read", "create", "update", "delete", "upload"],
    events: ["read", "create", "update", "delete", "upload"],
    announcements: ["read", "create", "update", "delete"],
    history: ["read", "create", "update", "delete", "upload"],
    jobs: ["read", "create", "update", "delete", "upload"],
    jobApplications: ["read", "update"],
    polls: ["read", "create", "update", "delete"],
    conversations: ["read", "create", "update", "delete", "message", "upload"],
    notifications: ["read"],
    activityLogs: ["read"],
  };
}

function emptyDashboardPermissions(): DashboardPermissionMap {
  return allDashboardResources.reduce((permissions, resource) => {
    permissions[resource] = [];
    return permissions;
  }, {} as DashboardPermissionMap);
}

async function hasDashboardPermission(req: express.Request, resourceName: string, permission: DashboardPermission) {
  const user = await getDashboardUser(req);
  const permissions = dashboardPermissionsFor(user);
  return Boolean((permissions as Record<string, DashboardPermission[]>)[resourceName]?.includes(permission));
}

const requireDashboardAccess: express.RequestHandler = (req, res, next) => {
  void getDashboardUser(req)
    .then((user) => {
      if (!canUseDashboard(user)) {
        return res.status(403).json({ message: "Dashboard access required" });
      }
      return next();
    })
    .catch(next);
};

async function scopedWhere(req: express.Request, resourceName: string, baseWhere: Record<string, unknown> = {}) {
  const user = await getDashboardUser(req);
  if (isFullAdmin(user) || !ownedResourceNames.has(resourceName)) return baseWhere;
  return { ...baseWhere, creatorId: req.user!.id };
}

async function dashboardResourceWhere(req: express.Request, resourceName: string, baseWhere: Record<string, unknown> = {}) {
  const user = await getDashboardUser(req);
  if (isFullAdmin(user)) return baseWhere;
  if (resourceName === "jobApplications") return { ...baseWhere, job: { creatorId: req.user!.id } };
  if (ownedResourceNames.has(resourceName)) return { ...baseWhere, creatorId: req.user!.id };
  return { ...baseWhere, id: "__no_access__" };
}

async function ensureCanMutate(
  req: express.Request,
  resourceName: string,
  id: string,
  delegate: any,
  permission: "update" | "delete" | "message" = "update"
) {
  const user = await getDashboardUser(req);
  if (!(await hasDashboardPermission(req, resourceName, permission))) return false;
  if (isFullAdmin(user)) return true;
  if (!executiveWritableResourceNames.has(resourceName)) return false;
  if (resourceName === "jobApplications") {
    const row = await db.jobApplication.findFirst({
      where: { id, job: { creatorId: req.user!.id } },
      select: { id: true }
    });
    return Boolean(row);
  }
  if (!ownedResourceNames.has(resourceName)) return false;
  const row = await delegate.findFirst({ where: { id, creatorId: req.user!.id }, select: { id: true } });
  return Boolean(row);
}

async function canCreateResource(req: express.Request, resourceName: string) {
  return hasDashboardPermission(req, resourceName, "create");
}

async function ownedCreateData(req: express.Request, resourceName: string, data: Record<string, unknown>) {
  if (!ownedResourceNames.has(resourceName)) return data;
  const user = await getDashboardUser(req);
  if (isFullAdmin(user) && data.creatorId) return data;
  return { ...data, creatorId: req.user!.id };
}

type ActivityAction = "CREATE" | "UPDATE" | "DELETE" | "MESSAGE" | "UPLOAD";

function resourceTitleFromRow(row?: Record<string, unknown> | null) {
  if (!row) return undefined;
  return String(
    row.title ??
      row.fullName ??
      row.name ??
      row.question ??
      row.email ??
      row.topic ??
      row.company ??
      row.id ??
      ""
  ) || undefined;
}

function requestIp(req: express.Request) {
  const forwardedFor = req.header("x-forwarded-for");
  return forwardedFor?.split(",")[0]?.trim() || req.ip;
}

function changedFields(data: Record<string, unknown>) {
  return Object.keys(data).filter((key) => !["password", "passwordHash"].includes(key));
}

async function writeActivityLog(
  req: express.Request,
  details: {
    action: ActivityAction;
    resource: string;
    resourceId?: string | null;
    resourceTitle?: string | null;
    metadata?: Record<string, unknown>;
  }
) {
  try {
    const actor = await prisma.user.findUnique({
      where: { id: req.user!.id },
      select: { id: true, fullName: true, email: true }
    });

    await db.activityLog.create({
      data: {
        actorId: actor?.id ?? req.user!.id,
        actorName: actor?.fullName ?? null,
        actorEmail: actor?.email ?? req.user!.email,
        action: details.action,
        resource: details.resource,
        resourceId: details.resourceId ?? undefined,
        resourceTitle: details.resourceTitle ?? undefined,
        metadata: details.metadata ?? undefined,
        ipAddress: requestIp(req),
        userAgent: req.header("user-agent") ?? undefined
      }
    });
  } catch (error) {
    console.warn("Activity log write failed", error);
  }
}

type NotificationPayload = {
  id: string;
  title: string;
  body: string;
  audience?: string;
  userId?: string | null;
};

type PushPayload = {
  title: string;
  body: string;
  data: Record<string, string>;
  userId?: string | null;
  audience?: string | null;
};

async function sendPushForNotification(notification: NotificationPayload) {
  await sendPush({
    title: notification.title,
    body: notification.body,
    userId: notification.userId,
    audience: notification.audience,
    data: {
      type: "notification",
      notificationId: notification.id
    }
  });
}

async function sendContentUpdatePush(resourceName: string, row: Record<string, unknown>) {
  if (!shouldPushContentUpdate(resourceName, row)) return;
  const label = resourceLabel(resourceName);
  const title = String(row.title ?? row.question ?? label);
  await sendPush({
    title: `New ${label}`,
    body: title,
    data: {
      type: "content_update",
      resource: resourceName,
      recordId: String(row.id ?? "")
    }
  });
}

function shouldPushContentUpdate(resourceName: string, row: Record<string, unknown>) {
  if (!["news", "events", "announcements", "history", "jobs", "polls"].includes(resourceName)) return false;
  return row.status === "PUBLISHED";
}

function resourceLabel(resourceName: string) {
  return ({
    news: "news",
    events: "event",
    announcements: "announcement",
    history: "history entry",
    jobs: "job",
    polls: "poll"
  } as Record<string, string>)[resourceName] ?? "update";
}

function notificationAudiencesForUser(user?: { role: string; organizationRole: string | null } | null) {
  const audiences = ["ALL"];
  if (!user) return audiences;
  if (user.role === "SUPER_ADMIN") audiences.push("SUPER_ADMINS", "ADMINS");
  if (user.role === "ADMIN") audiences.push("ADMINS");
  if (user.role === "USER" && user.organizationRole) audiences.push("EXECUTIVES");
  if (user.role === "USER" && !user.organizationRole) audiences.push("MEMBERS");
  return audiences;
}

function notificationAudienceUserWhere(audience?: string | null) {
  if (!audience || audience === "ALL") return {};
  if (audience === "MEMBERS") {
    return { user: { role: "USER", organizationRole: null } };
  }
  if (audience === "EXECUTIVES") {
    return { user: { role: "USER", organizationRole: { not: null } } };
  }
  if (audience === "ADMINS") {
    return { user: { role: { in: ["ADMIN", "SUPER_ADMIN"] } } };
  }
  if (audience === "SUPER_ADMINS") {
    return { user: { role: "SUPER_ADMIN" } };
  }
  return {};
}

async function sendPush(payload: PushPayload) {
  if (!firebaseReady) return;

  const tokens = await db.deviceToken.findMany({
    where: {
      enabled: true,
      ...(payload.userId ? { userId: payload.userId } : {}),
      ...notificationAudienceUserWhere(payload.audience)
    },
    select: { id: true, token: true }
  });
  if (!tokens.length) return;

  const messaging = getMessaging();
  const invalidTokenIds: string[] = [];
  const chunkSize = 500;

  for (let index = 0; index < tokens.length; index += chunkSize) {
    const chunk = tokens.slice(index, index + chunkSize);
    const response = await messaging.sendEachForMulticast({
      tokens: chunk.map((item: { token: string }) => item.token),
      notification: {
        title: payload.title,
        body: payload.body
      },
      data: payload.data
    });

    response.responses.forEach((result, resultIndex) => {
      if (!result.success && result.error?.code?.includes("registration-token")) {
        invalidTokenIds.push(chunk[resultIndex].id);
      }
    });
  }

  if (invalidTokenIds.length) {
    await db.deviceToken.deleteMany({ where: { id: { in: invalidTokenIds } } });
  }
}

const executiveWhere = {
  role: "USER" as const,
  organizationRole: { not: null }
};

app.use("/api/admin", adminRateLimit);

app.get("/api/admin/me", requireAuth, requireDashboardAccess, asyncHandler(async (req, res) => {
  const user = await getDashboardUser(req);
  res.json({
    user,
    permissions: dashboardPermissionsFor(user)
  });
}));

app.get("/api/admin/executives", requireAuth, requireDashboardAccess, asyncHandler(async (req, res) => {
  if (!(await hasDashboardPermission(req, "executives", "read"))) {
    return res.status(403).json({ message: "You do not have permission to view executives" });
  }
  const { page, pageSize } = adminListQuerySchema.parse(req.query);
  const skip = (page - 1) * pageSize;
  const user = await getDashboardUser(req);
  const where = isFullAdmin(user) ? executiveWhere : { id: req.user!.id, ...executiveWhere };
  const [rows, total] = await Promise.all([
    prisma.user.findMany({
      where,
      select: publicUserSelect,
      orderBy: { fullName: "asc" },
      skip,
      take: pageSize
    }),
    prisma.user.count({ where })
  ]);

  res.json({
    rows,
    page,
    pageSize,
    total,
    totalPages: Math.ceil(total / pageSize)
  });
}));

app.get("/api/admin/executives/:id", requireAuth, requireDashboardAccess, asyncHandler(async (req, res) => {
  if (!(await hasDashboardPermission(req, "executives", "read"))) {
    return res.status(403).json({ message: "You do not have permission to view executives" });
  }
  const user = await getDashboardUser(req);
  const row = await prisma.user.findFirst({
    where: { id: String(req.params.id), ...executiveWhere, ...(isFullAdmin(user) ? {} : { id: req.user!.id }) },
    select: publicUserSelect
  });
  if (!row) return res.status(404).json({ message: "Executive not found" });
  return res.json({ row });
}));

app.post("/api/admin/executives", requireAuth, requireAdmin, asyncHandler(async (req, res) => {
  const parsed = adminSchemas.users.create.parse({
    ...req.body,
    role: "USER",
    status: req.body.status ?? "ACTIVE",
    organizationRole: req.body.organizationRole ?? "Chapter Executive"
  });
  const passwordHash = await hashPassword(parsed.password ?? createRefreshToken());
  const data = { ...parsed, passwordHash };
  delete (data as any).password;
  const row = await prisma.user.create({ data: data as any, select: publicUserSelect });
  await writeActivityLog(req, {
    action: "CREATE",
    resource: "executives",
    resourceId: row.id,
    resourceTitle: row.fullName,
    metadata: { fields: changedFields(data) }
  });
  res.status(201).json({ row });
}));

app.patch("/api/admin/executives/:id", requireAuth, requireAdmin, asyncHandler(async (req, res) => {
  const parsed = adminSchemas.users.update.parse({
    ...req.body,
    role: "USER",
    organizationRole: req.body.organizationRole ?? "Chapter Executive"
  });
  const data = { ...parsed };
  if (data.password) {
    (data as any).passwordHash = await hashPassword(data.password);
    delete (data as any).password;
  }
  const row = await prisma.user.update({
    where: { id: String(req.params.id) },
    data: data as any,
    select: publicUserSelect
  });
  await writeActivityLog(req, {
    action: "UPDATE",
    resource: "executives",
    resourceId: row.id,
    resourceTitle: row.fullName,
    metadata: { fields: changedFields(data) }
  });
  res.json({ row });
}));

app.delete("/api/admin/executives/:id", requireAuth, requireAdmin, asyncHandler(async (req, res) => {
  const existing = await prisma.user.findUnique({
    where: { id: String(req.params.id) },
    select: publicUserSelect
  });
  await prisma.user.delete({ where: { id: String(req.params.id) } });
  await writeActivityLog(req, {
    action: "DELETE",
    resource: "executives",
    resourceId: String(req.params.id),
    resourceTitle: existing?.fullName
  });
  res.status(204).send();
}));

for (const [name, config] of Object.entries(resources)) {
  const router = express.Router();
  router.use(requireAuth, requireDashboardAccess);

  router.get("/", asyncHandler(async (req, res) => {
    if (!(await hasDashboardPermission(req, name, "read"))) {
      return res.status(403).json({ message: `You do not have permission to view ${name}` });
    }
    const { page, pageSize } = adminListQuerySchema.parse(req.query);
    const skip = (page - 1) * pageSize;
    const where = await dashboardResourceWhere(req, name, (config as any).where ?? {});
    const [rows, total] = await Promise.all([
      (config.delegate as any).findMany({
        where,
        ...(config as any).include ? { include: (config as any).include } : {},
        ...(config as any).select ? { select: (config as any).select } : {},
        orderBy: { createdAt: "desc" },
        skip,
        take: pageSize
      }),
      (config.delegate as any).count({ where })
    ]);

    res.json({
      rows,
      page,
      pageSize,
      total,
      totalPages: Math.ceil(total / pageSize)
    });
  }));

  router.get("/:id", asyncHandler(async (req, res) => {
    if (!(await hasDashboardPermission(req, name, "read"))) {
      return res.status(403).json({ message: `You do not have permission to view ${name}` });
    }
    const where = await dashboardResourceWhere(req, name, { ...((config as any).where ?? {}), id: String(req.params.id) });
    const row = await (config.delegate as any).findFirst({
      where,
      ...(config as any).include ? { include: (config as any).include } : {},
      ...(config as any).select ? { select: (config as any).select } : {}
    });
    if (!row) return res.status(404).json({ message: "Not found" });
    return res.json({ row });
  }));

  router.post("/", asyncHandler(async (req, res) => {
    if ((config as any).readOnly) {
      return res.status(405).json({ message: "This resource is read-only" });
    }
    if (!(await canCreateResource(req, name))) {
      return res.status(403).json({ message: "You do not have permission to create this record" });
    }
    const parsed = (adminSchemas as any)[name].create.parse(req.body);
    const rawData = (config as any).scrubCreate
      ? await (config as any).scrubCreate(parsed)
      : parsed;
    const data = await ownedCreateData(req, name, rawData);
    delete data.password;
    if (name === "polls") {
      const options = data.options as string[];
      data.options = {
        create: options.map((text) => ({ text }))
      };
    }
    const row = await (config.delegate as any).create({
      data,
      ...(config as any).include ? { include: (config as any).include } : {},
      ...(config as any).select ? { select: (config as any).select } : {}
    });
    if (name === "conversations") {
      await db.conversationParticipant.upsert({
        where: { conversationId_userId: { conversationId: row.id, userId: req.user!.id } },
        update: { role: "OWNER" },
        create: { conversationId: row.id, userId: req.user!.id, role: "OWNER" }
      });
    }
    if (name === "notifications") {
      await sendPushForNotification(row);
    } else {
      await sendContentUpdatePush(name, row);
    }
    await writeActivityLog(req, {
      action: "CREATE",
      resource: name,
      resourceId: row.id,
      resourceTitle: resourceTitleFromRow(row),
      metadata: { fields: changedFields(rawData) }
    });
    res.status(201).json({ row });
  }));

  router.patch("/:id", asyncHandler(async (req, res) => {
    if ((config as any).readOnly) {
      return res.status(405).json({ message: "This resource is read-only" });
    }
    if (!(await ensureCanMutate(req, name, String(req.params.id), config.delegate, "update"))) {
      return res.status(403).json({ message: "You do not have permission to edit this record" });
    }
    if ((config as any).where) {
      const target = await (config.delegate as any).findFirst({
        where: { ...((config as any).where ?? {}), id: String(req.params.id) },
        select: { id: true }
      });
      if (!target) return res.status(404).json({ message: "Not found" });
    }
    const parsed = (adminSchemas as any)[name].update.parse(req.body);
    if (
      name === "adminUsers" &&
      String(req.params.id) === req.user!.id &&
      (parsed.role === "ADMIN" || parsed.status === "SUSPENDED")
    ) {
      return res.status(400).json({ message: "You cannot demote or suspend your own super admin account" });
    }
    const data = { ...parsed };
    if ((name === "users" || name === "adminUsers") && data.password) {
      data.passwordHash = await hashPassword(data.password);
      delete data.password;
    }
    if (name === "polls" && Array.isArray(data.options)) {
      const optionTexts = data.options as string[];
      delete data.options;
      await prisma.pollOption.deleteMany({
        where: {
          pollId: String(req.params.id),
          votes: { none: {} }
        }
      });
      for (const text of optionTexts) {
        const existing = await prisma.pollOption.findFirst({
          where: { pollId: String(req.params.id), text },
          select: { id: true }
        });
        if (!existing) {
          await prisma.pollOption.create({
            data: { pollId: String(req.params.id), text }
          });
        }
      }
    }
    const row = await (config.delegate as any).update({
      where: { id: String(req.params.id) },
      data,
      ...(config as any).include ? { include: (config as any).include } : {},
      ...(config as any).select ? { select: (config as any).select } : {}
    });
    await writeActivityLog(req, {
      action: "UPDATE",
      resource: name,
      resourceId: row.id,
      resourceTitle: resourceTitleFromRow(row),
      metadata: { fields: changedFields(data) }
    });
    res.json({ row });
  }));

  router.delete("/:id", asyncHandler(async (req, res) => {
    if ((config as any).readOnly) {
      return res.status(405).json({ message: "This resource is read-only" });
    }
    if (name === "adminUsers" && String(req.params.id) === req.user!.id) {
      return res.status(400).json({ message: "You cannot delete your own admin account" });
    }
    if (!(await ensureCanMutate(req, name, String(req.params.id), config.delegate, "delete"))) {
      return res.status(403).json({ message: "You do not have permission to delete this record" });
    }
    const existing = await (config.delegate as any).findFirst({
      where: { ...((config as any).where ?? {}), id: String(req.params.id) },
      ...(config as any).select ? { select: (config as any).select } : {}
    });
    if (!existing) return res.status(404).json({ message: "Not found" });
    await (config.delegate as any).delete({ where: { id: String(req.params.id) } });
    await writeActivityLog(req, {
      action: "DELETE",
      resource: name,
      resourceId: String(req.params.id),
      resourceTitle: resourceTitleFromRow(existing)
    });
    res.status(204).send();
  }));

  app.use(`/api/admin/${name}`, router);
}

app.get("/api/admin/conversations/:id/messages", requireAuth, requireDashboardAccess, asyncHandler(async (req, res) => {
  if (!(await hasDashboardPermission(req, "conversations", "read"))) {
    return res.status(403).json({ message: "You do not have permission to view chat messages" });
  }
  const id = String(req.params.id);
  const where = await dashboardResourceWhere(req, "conversations", { id });
  const conversation = await db.conversation.findFirst({
    where,
    select: { id: true }
  });
  if (!conversation) return res.status(404).json({ message: "Conversation not found" });

  const messages = await db.message.findMany({
    where: { conversationId: id },
    include: publicMessageInclude,
    orderBy: { createdAt: "asc" },
    take: 100
  });
  res.json({ messages });
}));

app.post("/api/admin/conversations/:id/messages", requireAuth, requireDashboardAccess, asyncHandler(async (req, res) => {
  const id = String(req.params.id);
  const body = z.object({
    body: z.string().max(1000).default(""),
    mediaUrl: optionalImageReferenceSchema,
    mediaType: optionalStringSchema
  }).refine((value) => value.body.trim().length > 0 || Boolean(value.mediaUrl), {
    message: "Message text or media is required"
  }).parse(req.body);

  const canMessage = await ensureCanMutate(req, "conversations", id, db.conversation, "message");
  if (!canMessage) {
    return res.status(403).json({ message: "You do not have permission to message this chat room" });
  }
  const conversation = await db.conversation.findUnique({
    where: { id },
    select: { title: true }
  });

  const message = await db.message.create({
    data: {
      body: body.body,
      mediaUrl: body.mediaUrl ?? undefined,
      mediaType: body.mediaType ?? undefined,
      conversationId: id,
      authorId: req.user!.id
    },
    include: publicMessageInclude
  });
  await db.conversation.update({
    where: { id },
    data: { updatedAt: new Date() }
  });
  await writeActivityLog(req, {
    action: "MESSAGE",
    resource: "conversations",
    resourceId: id,
    resourceTitle: conversation?.title,
    metadata: {
      hasText: Boolean(body.body.trim()),
      hasMedia: Boolean(body.mediaUrl),
      mediaType: body.mediaType
    }
  });
  res.status(201).json({ message });
}));

app.post("/api/admin/polls/:pollId/options", requireAuth, requireDashboardAccess, asyncHandler(async (req, res) => {
  const pollId = String(req.params.pollId);
  const body = z.object({ text: z.string().min(1) }).parse(req.body);
  const canEdit = await ensureCanMutate(req, "polls", pollId, prisma.poll, "update");
  if (!canEdit) return res.status(403).json({ message: "You do not have permission to update this poll" });
  const option = await prisma.pollOption.create({
    data: { pollId, text: body.text }
  });
  await writeActivityLog(req, {
    action: "UPDATE",
    resource: "polls",
    resourceId: pollId,
    resourceTitle: "Poll option added",
    metadata: { fields: ["options"] }
  });
  res.status(201).json({ option });
}));

app.post(
  "/api/admin/uploads",
  requireAuth,
  requireDashboardAccess,
  asyncHandler(async (req, res, next) => {
    if (!(await hasDashboardPermission(req, "news", "upload"))) {
      return res.status(403).json({ message: "You do not have permission to upload media" });
    }
    return next();
  }),
  upload.single("file"),
  asyncHandler(async (req, res) => {
    if (!req.file) {
      return res.status(400).json({ message: "Image file is required" });
    }

    if (useBlobStorage) {
      const extension = path.extname(req.file.originalname).toLowerCase();
      const filename = `uploads/${crypto.randomUUID()}${extension}`;
      const blob = await put(filename, req.file.buffer, {
        access: "public",
        contentType: req.file.mimetype
      });

      await writeActivityLog(req, {
        action: "UPLOAD",
        resource: "uploads",
        resourceId: filename,
        resourceTitle: req.file.originalname,
        metadata: { contentType: req.file.mimetype, size: req.file.size, storage: "blob" }
      });

      return res.status(201).json({
        url: blob.url,
        filename,
        contentType: req.file.mimetype,
        size: req.file.size
      });
    }

    await writeActivityLog(req, {
      action: "UPLOAD",
      resource: "uploads",
      resourceId: req.file.filename,
      resourceTitle: req.file.originalname,
      metadata: { contentType: req.file.mimetype, size: req.file.size, storage: "local" }
    });

    return res.status(201).json({
      url: `/uploads/${req.file.filename}`,
      filename: req.file.filename,
      contentType: req.file.mimetype,
      size: req.file.size
    });
  })
);

app.use((err: unknown, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  if (err instanceof z.ZodError) {
    return res.status(400).json({
      message: readableValidationMessage(err),
      issues: err.issues
    });
  }

  if (err instanceof PrismaClientKnownRequestError) {
    if (err.code === "P2002") {
      return res.status(409).json({ message: duplicateRecordMessage(err) });
    }

    if (err.code === "P2025") {
      return res.status(404).json({ message: "Record not found" });
    }
  }

  if (
    err instanceof PrismaClientInitializationError ||
    (err instanceof Error && err.name === "PrismaClientInitializationError")
  ) {
    return res.status(503).json({ message: "Database is unavailable" });
  }

  console.error(err);
  return res.status(500).json({ message: "Something went wrong" });
});

function readableValidationMessage(error: z.ZodError) {
  const issue = error.issues[0];
  if (!issue) return "Please check the information you entered and try again";

  const field = readableFieldName(issue.path);
  return field ? `${field}: ${issue.message}` : issue.message;
}

function duplicateRecordMessage(error: PrismaClientKnownRequestError) {
  const target = Array.isArray(error.meta?.target) ? error.meta?.target : [];
  const fields = target.map((field) => readableFieldName([field])).filter(Boolean);

  if (fields.includes("Email")) {
    return "An account with this email already exists. Please sign in instead.";
  }

  if (fields.length) {
    return `${fields.join(", ")} already exists. Please use a different value.`;
  }

  return "A record with this information already exists. Please use different details.";
}

function readableFieldName(pathParts: (string | number)[]) {
  const raw = String(pathParts.at(-1) ?? "");
  if (!raw) return "";

  const labels: Record<string, string> = {
    fullName: "Full name",
    email: "Email",
    password: "Password",
    phone: "Phone number",
    institution: "Institution"
  };

  return labels[raw] ?? raw.replace(/([A-Z])/g, " $1").replace(/^./, (letter) => letter.toUpperCase());
}

function toPublicUser(user: {
  id: string;
  email: string;
  fullName: string;
  phone: string | null;
  institution: string | null;
  avatarUrl: string | null;
  bio: string | null;
  organizationRole: string | null;
  role: "USER" | "ADMIN" | "SUPER_ADMIN";
  status: "PENDING" | "ACTIVE" | "SUSPENDED";
  chapterId: string | null;
  createdAt: Date;
  updatedAt: Date;
}) {
  return {
    id: user.id,
    email: user.email,
    fullName: user.fullName,
    phone: user.phone,
    institution: user.institution,
    avatarUrl: user.avatarUrl,
    bio: user.bio,
    organizationRole: user.organizationRole,
    role: user.role,
    status: user.status,
    chapterId: user.chapterId,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt
  };
}

async function createSession(user: {
  id: string;
  email: string;
  role: "USER" | "ADMIN" | "SUPER_ADMIN";
}) {
  const refreshToken = createRefreshToken();
  await prisma.refreshToken.create({
    data: {
      userId: user.id,
      tokenHash: hashRefreshToken(refreshToken),
      expiresAt: tokenExpiry(30 * 24 * 60 * 60)
    }
  });

  return getTokenPair(user, refreshToken);
}

export { app };
