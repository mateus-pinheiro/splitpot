-- CreateEnum
CREATE TYPE "ActionType" AS ENUM ('BUYIN', 'REBUY', 'LEAVE', 'REJOIN');

-- CreateEnum
CREATE TYPE "ActionRequestStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- CreateTable
CREATE TABLE "action_requests" (
    "id" TEXT NOT NULL,
    "tableId" TEXT NOT NULL,
    "participationId" TEXT NOT NULL,
    "requestedById" TEXT NOT NULL,
    "type" "ActionType" NOT NULL,
    "amount" DECIMAL(12,2),
    "status" "ActionRequestStatus" NOT NULL DEFAULT 'PENDING',
    "requestedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "resolvedAt" TIMESTAMP(3),

    CONSTRAINT "action_requests_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "action_requests_tableId_idx" ON "action_requests"("tableId");

-- CreateIndex
CREATE INDEX "action_requests_participationId_idx" ON "action_requests"("participationId");

-- CreateIndex
CREATE INDEX "action_requests_requestedById_idx" ON "action_requests"("requestedById");

-- AddForeignKey
ALTER TABLE "action_requests" ADD CONSTRAINT "action_requests_tableId_fkey" FOREIGN KEY ("tableId") REFERENCES "tables"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "action_requests" ADD CONSTRAINT "action_requests_participationId_fkey" FOREIGN KEY ("participationId") REFERENCES "table_participations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "action_requests" ADD CONSTRAINT "action_requests_requestedById_fkey" FOREIGN KEY ("requestedById") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
