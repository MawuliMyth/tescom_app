-- CreateTable
CREATE TABLE "HistoryEntry" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "summary" TEXT,
    "body" TEXT NOT NULL,
    "category" TEXT,
    "occurredAt" TIMESTAMP(3),
    "imageUrl" TEXT,
    "status" "PublishStatus" NOT NULL DEFAULT 'PUBLISHED',
    "creatorId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "HistoryEntry_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "HistoryEntry_creatorId_idx" ON "HistoryEntry"("creatorId");

-- CreateIndex
CREATE INDEX "HistoryEntry_status_idx" ON "HistoryEntry"("status");

-- CreateIndex
CREATE INDEX "HistoryEntry_occurredAt_idx" ON "HistoryEntry"("occurredAt");

-- AddForeignKey
ALTER TABLE "HistoryEntry" ADD CONSTRAINT "HistoryEntry_creatorId_fkey" FOREIGN KEY ("creatorId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
