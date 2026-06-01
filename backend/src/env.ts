import "dotenv/config";
import { z } from "zod";

const envSchema = z.object({
  DATABASE_URL: z.string().min(1),
  JWT_SECRET: z.string().min(24),
  CORS_ORIGIN: z.string().optional(),
  BLOB_READ_WRITE_TOKEN: z.string().optional(),
  PORT: z.coerce.number().default(4000)
});

export const env = envSchema.parse(process.env);
