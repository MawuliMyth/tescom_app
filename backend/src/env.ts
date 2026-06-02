import "dotenv/config";
import { z } from "zod";

const envSchema = z.object({
  DATABASE_URL: z.string().min(1),
  JWT_SECRET: z.string().min(24),
  CORS_ORIGIN: z.string().optional(),
  BLOB_READ_WRITE_TOKEN: z.string().optional(),
  SMTP_HOST: z.string().optional(),
  SMTP_PORT: z.coerce.number().optional(),
  SMTP_USER: z.string().optional(),
  SMTP_PASS: z.string().optional(),
  SMTP_FROM: z.string().optional(),
  SMTP_ENABLED: z.coerce.boolean().default(false),
  PORT: z.coerce.number().default(4000)
});

export const env = envSchema.parse(process.env);
