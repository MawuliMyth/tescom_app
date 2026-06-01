import "dotenv/config";
import { PrismaClient } from "@prisma/client";
import { hashPassword } from "../src/utils/auth.js";

const prisma = new PrismaClient();

async function main() {
  const adminEmail = process.env.ADMIN_EMAIL ?? "admin@tescon.app";
  const adminPassword = process.env.ADMIN_PASSWORD;

  if (!adminPassword || adminPassword.length < 8) {
    throw new Error("ADMIN_PASSWORD must be set and at least 8 characters.");
  }

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

  console.log(`Admin ready: ${adminEmail}`);
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
