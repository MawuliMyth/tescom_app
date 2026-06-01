import cors from "cors";
import express from "express";
import multer from "multer";
import { put } from "@vercel/blob";
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

const corsOrigins = env.CORS_ORIGIN?.split(",").map((origin) => origin.trim()).filter(Boolean);
const uploadDir = path.resolve("storage/uploads");
const imageMimeTypes = new Set(["image/jpeg", "image/png", "image/webp", "image/gif"]);
const useBlobStorage = Boolean(env.BLOB_READ_WRITE_TOKEN);

fs.mkdirSync(uploadDir, { recursive: true });

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
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (_req, file, callback) => {
    callback(null, imageMimeTypes.has(file.mimetype));
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

const publishStatusSchema = z.enum(["DRAFT", "PUBLISHED", "ARCHIVED"]);
const userRoleSchema = z.enum(["USER", "ADMIN", "SUPER_ADMIN"]);
const userStatusSchema = z.enum(["PENDING", "ACTIVE", "SUSPENDED"]);
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
const optionalImageReferenceSchema = imageReferenceSchema.nullable().optional();
const imageReferencesSchema = z.array(imageReferenceSchema).max(10).default([]);
const optionalImageReferencesSchema = z.array(imageReferenceSchema).max(10).optional();

const adminListQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  pageSize: z.coerce.number().int().min(1).max(100).default(25)
});

const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  fullName: z.string().min(2),
  phone: z.string().optional(),
  institution: z.string().optional()
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1)
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
      status: publishStatusSchema.default("DRAFT"),
      closesAt: optionalDateSchema
    }),
    update: z.object({
      question: z.string().min(2).optional(),
      description: z.string().optional(),
      status: publishStatusSchema.optional(),
      closesAt: optionalDateSchema
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
      userId: z.string().optional(),
      readAt: optionalDateSchema
    }),
    update: z.object({
      title: z.string().min(2).optional(),
      body: z.string().min(2).optional(),
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

app.get("/api/app/bootstrap", asyncHandler(async (_req, res) => {
  const [news, events, announcements, jobs, rawChapters, polls] = await Promise.all([
    prisma.newsArticle.findMany(publishedOrder()),
    prisma.event.findMany(publishedOrder()),
    prisma.announcement.findMany(publishedOrder()),
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

  res.json({ news, events, announcements, jobs, chapters, polls });
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

app.get("/api/app/members", requireAuth, asyncHandler(async (_req, res) => {
  const members = await prisma.user.findMany({
    where: { status: "ACTIVE", role: "USER" },
    select: publicUserSelect,
    orderBy: { fullName: "asc" },
    take: 200
  });
  res.json({ members });
}));

app.get("/api/app/executives", requireAuth, asyncHandler(async (_req, res) => {
  const executives = await prisma.user.findMany({
    where: {
      status: "ACTIVE",
      role: "USER",
      organizationRole: { not: null }
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
  const notifications = await prisma.notification.findMany({
    where: {
      OR: [{ userId: null }, { userId: req.user!.id }]
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

app.get("/api/app/conversations", requireAuth, asyncHandler(async (_req, res) => {
  const conversations = await prisma.conversation.findMany({
    include: publicConversationInclude,
    orderBy: { updatedAt: "desc" },
    take: 100
  });
  res.json({ conversations });
}));

app.get("/api/app/conversations/:id/messages", requireAuth, asyncHandler(async (req, res) => {
  const id = String(req.params.id);
  const conversation = await prisma.conversation.findUnique({
    where: { id },
    select: { id: true }
  });
  if (!conversation) return res.status(404).json({ message: "Conversation not found" });

  const messages = await prisma.message.findMany({
    where: { conversationId: id },
    include: publicMessageInclude,
    orderBy: { createdAt: "asc" },
    take: 100
  });
  res.json({ messages });
}));

app.post("/api/app/conversations/:id/messages", requireAuth, asyncHandler(async (req, res) => {
  const id = String(req.params.id);
  const body = z.object({ body: z.string().min(1).max(1000) }).parse(req.body);
  const conversation = await prisma.conversation.findUnique({
    where: { id },
    select: { id: true }
  });
  if (!conversation) return res.status(404).json({ message: "Conversation not found" });

  const message = await prisma.message.create({
    data: {
      body: body.body,
      conversationId: id,
      authorId: req.user!.id
    },
    include: publicMessageInclude
  });
  await prisma.conversation.update({
    where: { id },
    data: { updatedAt: new Date() }
  });
  res.status(201).json({ message });
}));

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
  jobs: { delegate: prisma.job },
  polls: { delegate: prisma.poll, include: { options: true } },
  conversations: { delegate: prisma.conversation, include: { messages: true } },
  notifications: { delegate: prisma.notification },
  contacts: { delegate: prisma.contactMessage }
} as const;

const executiveWhere = {
  role: "USER" as const,
  organizationRole: { not: null }
};

app.get("/api/admin/executives", requireAuth, requireAdmin, asyncHandler(async (req, res) => {
  const { page, pageSize } = adminListQuerySchema.parse(req.query);
  const skip = (page - 1) * pageSize;
  const [rows, total] = await Promise.all([
    prisma.user.findMany({
      where: executiveWhere,
      select: publicUserSelect,
      orderBy: { fullName: "asc" },
      skip,
      take: pageSize
    }),
    prisma.user.count({ where: executiveWhere })
  ]);

  res.json({
    rows,
    page,
    pageSize,
    total,
    totalPages: Math.ceil(total / pageSize)
  });
}));

app.get("/api/admin/executives/:id", requireAuth, requireAdmin, asyncHandler(async (req, res) => {
  const row = await prisma.user.findFirst({
    where: { id: String(req.params.id), ...executiveWhere },
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
  res.json({ row });
}));

app.delete("/api/admin/executives/:id", requireAuth, requireAdmin, asyncHandler(async (req, res) => {
  await prisma.user.delete({ where: { id: String(req.params.id) } });
  res.status(204).send();
}));

for (const [name, config] of Object.entries(resources)) {
  const router = express.Router();
  router.use(requireAuth, requireAdmin);

  router.get("/", asyncHandler(async (_req, res) => {
    const { page, pageSize } = adminListQuerySchema.parse(_req.query);
    const skip = (page - 1) * pageSize;
    const [rows, total] = await Promise.all([
      (config.delegate as any).findMany({
        ...(config as any).include ? { include: (config as any).include } : {},
        ...(config as any).select ? { select: (config as any).select } : {},
        orderBy: { createdAt: "desc" },
        skip,
        take: pageSize
      }),
      (config.delegate as any).count()
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
    const row = await (config.delegate as any).findUnique({
      where: { id: req.params.id },
      ...(config as any).include ? { include: (config as any).include } : {},
      ...(config as any).select ? { select: (config as any).select } : {}
    });
    if (!row) return res.status(404).json({ message: "Not found" });
    return res.json({ row });
  }));

  router.post("/", asyncHandler(async (req, res) => {
    const parsed = (adminSchemas as any)[name].create.parse(req.body);
    const data = (config as any).scrubCreate
      ? await (config as any).scrubCreate(parsed)
      : parsed;
    delete data.password;
    const row = await (config.delegate as any).create({ data });
    res.status(201).json({ row });
  }));

  router.patch("/:id", asyncHandler(async (req, res) => {
    const parsed = (adminSchemas as any)[name].update.parse(req.body);
    const data = { ...parsed };
    if (name === "users" && data.password) {
      data.passwordHash = await hashPassword(data.password);
      delete data.password;
    }
    const row = await (config.delegate as any).update({
      where: { id: req.params.id },
      data
    });
    res.json({ row });
  }));

  router.delete("/:id", asyncHandler(async (req, res) => {
    await (config.delegate as any).delete({ where: { id: req.params.id } });
    res.status(204).send();
  }));

  app.use(`/api/admin/${name}`, router);
}

app.post("/api/admin/polls/:pollId/options", requireAuth, requireAdmin, asyncHandler(async (req, res) => {
  const pollId = String(req.params.pollId);
  const body = z.object({ text: z.string().min(1) }).parse(req.body);
  const option = await prisma.pollOption.create({
    data: { pollId, text: body.text }
  });
  res.status(201).json({ option });
}));

app.post(
  "/api/admin/uploads",
  requireAuth,
  requireAdmin,
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

app.use((err: unknown, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  if (err instanceof z.ZodError) {
    return res.status(400).json({ message: "Validation failed", issues: err.issues });
  }

  if (err instanceof PrismaClientKnownRequestError) {
    if (err.code === "P2002") {
      return res.status(409).json({ message: "A record with this value already exists" });
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
