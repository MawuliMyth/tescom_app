import "dotenv/config";
import { PrismaClient } from "@prisma/client";
import { hashPassword } from "../src/utils/auth.js";

const prisma = new PrismaClient();

async function main() {
  const adminEmail = process.env.ADMIN_EMAIL ?? "admin@tescon.app";
  const adminPassword = process.env.ADMIN_PASSWORD ?? "ChangeMe123!";

  await prisma.user.upsert({
    where: { email: adminEmail },
    update: { role: "SUPER_ADMIN", status: "ACTIVE" },
    create: {
      email: adminEmail,
      passwordHash: await hashPassword(adminPassword),
      fullName: "TESCON Admin",
      role: "SUPER_ADMIN",
      status: "ACTIVE"
    }
  });

  const chapter = await prisma.chapter.upsert({
    where: { id: "seed-main-chapter" },
    update: {},
    create: {
      id: "seed-main-chapter",
      name: "TESCON Main Chapter",
      campus: "National",
      region: "Ghana",
      description: "Default chapter for initial setup."
    }
  });

  await prisma.newsArticle.create({
    data: {
      title: "Welcome to TESCON",
      summary: "The backend is ready for live content.",
      body: "Admins can replace this seed article from the panel.",
      status: "PUBLISHED",
      publishedAt: new Date()
    }
  });

  await prisma.event.create({
    data: {
      title: "Chapter Orientation",
      description: "Initial event placeholder.",
      venue: "Main Auditorium",
      startsAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      status: "PUBLISHED",
      chapterId: chapter.id
    }
  });
}

main()
  .finally(async () => {
    await prisma.$disconnect();
  })
  .catch(async (error) => {
    console.error(error);
    await prisma.$disconnect();
    process.exit(1);
  });
