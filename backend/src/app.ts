import cors from "cors";
import express from "express";
import { z } from "zod";
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

app.use(cors());
app.use(express.json({ limit: "2mb" }));

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
  role: true,
  status: true,
  chapterId: true,
  createdAt: true,
  updatedAt: true
} as const;

const publishedOrder = {
  where: { status: "PUBLISHED" as const },
  orderBy: { createdAt: "desc" as const }
};

app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "tescon-backend" });
});

app.post("/api/auth/register", async (req, res) => {
  const body = registerSchema.parse(req.body);
  const passwordHash = await hashPassword(body.password);
  const user = await prisma.user.create({
    data: { ...body, passwordHash, status: "ACTIVE" },
    select: publicUserSelect
  });

  const tokens = await createSession(user);
  res.status(201).json({ user, tokens });
});

app.post("/api/auth/login", async (req, res) => {
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
});

app.post("/api/auth/refresh", async (req, res) => {
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
});

app.post("/api/auth/logout", requireAuth, async (req, res) => {
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
});

app.get("/api/auth/me", requireAuth, async (req, res) => {
  const user = await prisma.user.findUnique({
    where: { id: req.user!.id },
    select: publicUserSelect
  });
  res.json({ user });
});

app.get("/api/app/bootstrap", async (_req, res) => {
  const [news, events, announcements, jobs, chapters, polls] = await Promise.all([
    prisma.newsArticle.findMany(publishedOrder),
    prisma.event.findMany(publishedOrder),
    prisma.announcement.findMany(publishedOrder),
    prisma.job.findMany(publishedOrder),
    prisma.chapter.findMany({ orderBy: { name: "asc" } }),
    prisma.poll.findMany({
      where: { status: "PUBLISHED" },
      include: { options: true },
      orderBy: { createdAt: "desc" }
    })
  ]);

  res.json({ news, events, announcements, jobs, chapters, polls });
});

app.post("/api/app/contact", async (req, res) => {
  const body = z.object({
    name: z.string().min(2),
    email: z.string().email(),
    topic: z.string().min(2),
    message: z.string().min(5)
  }).parse(req.body);

  const contactMessage = await prisma.contactMessage.create({ data: body });
  res.status(201).json({ contactMessage });
});

app.post("/api/app/polls/:pollId/vote", requireAuth, async (req, res) => {
  const pollId = String(req.params.pollId);
  const body = z.object({ optionId: z.string().min(1) }).parse(req.body);
  const vote = await prisma.pollVote.upsert({
    where: { pollId_userId: { pollId, userId: req.user!.id } },
    update: { optionId: body.optionId },
    create: { pollId, optionId: body.optionId, userId: req.user!.id }
  });

  res.status(201).json({ vote });
});

const resources = {
  users: {
    delegate: prisma.user,
    select: publicUserSelect,
    scrubCreate: async (data: any) => ({
      ...data,
      passwordHash: data.password ? await hashPassword(data.password) : data.passwordHash
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

for (const [name, config] of Object.entries(resources)) {
  const router = express.Router();
  router.use(requireAuth, requireAdmin);

  router.get("/", async (_req, res) => {
    const rows = await (config.delegate as any).findMany({
      ...(config as any).include ? { include: (config as any).include } : {},
      ...(config as any).select ? { select: (config as any).select } : {},
      orderBy: { createdAt: "desc" }
    });
    res.json({ rows });
  });

  router.get("/:id", async (req, res) => {
    const row = await (config.delegate as any).findUnique({
      where: { id: req.params.id },
      ...(config as any).include ? { include: (config as any).include } : {},
      ...(config as any).select ? { select: (config as any).select } : {}
    });
    if (!row) return res.status(404).json({ message: "Not found" });
    return res.json({ row });
  });

  router.post("/", async (req, res) => {
    const data = (config as any).scrubCreate
      ? await (config as any).scrubCreate(req.body)
      : req.body;
    delete data.password;
    const row = await (config.delegate as any).create({ data });
    res.status(201).json({ row });
  });

  router.patch("/:id", async (req, res) => {
    const data = { ...req.body };
    if (name === "users" && data.password) {
      data.passwordHash = await hashPassword(data.password);
      delete data.password;
    }
    const row = await (config.delegate as any).update({
      where: { id: req.params.id },
      data
    });
    res.json({ row });
  });

  router.delete("/:id", async (req, res) => {
    await (config.delegate as any).delete({ where: { id: req.params.id } });
    res.status(204).send();
  });

  app.use(`/api/admin/${name}`, router);
}

app.post("/api/admin/polls/:pollId/options", requireAuth, requireAdmin, async (req, res) => {
  const pollId = String(req.params.pollId);
  const body = z.object({ text: z.string().min(1) }).parse(req.body);
  const option = await prisma.pollOption.create({
    data: { pollId, text: body.text }
  });
  res.status(201).json({ option });
});

app.use((err: unknown, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  if (err instanceof z.ZodError) {
    return res.status(400).json({ message: "Validation failed", issues: err.issues });
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
