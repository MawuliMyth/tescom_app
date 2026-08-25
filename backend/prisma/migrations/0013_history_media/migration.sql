-- AlterTable
ALTER TABLE "HistoryEntry" ADD COLUMN "mediaUrl" TEXT;
ALTER TABLE "HistoryEntry" ADD COLUMN "mediaType" TEXT;

-- Backfill existing image-only records into the more general media fields.
UPDATE "HistoryEntry"
SET "mediaUrl" = "imageUrl", "mediaType" = 'image'
WHERE "imageUrl" IS NOT NULL AND "mediaUrl" IS NULL;
