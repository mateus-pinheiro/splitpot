-- CreateEnum
CREATE TYPE "TableStatus" AS ENUM ('OPEN', 'CLOSED');

-- CreateEnum
CREATE TYPE "SettlementStatus" AS ENUM ('PENDING', 'CONFIRMED');

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "firebaseUid" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "pixKey" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tables" (
    "id" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "minBuyIn" DECIMAL(12,2) NOT NULL,
    "status" "TableStatus" NOT NULL DEFAULT 'OPEN',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "closedAt" TIMESTAMP(3),

    CONSTRAINT "tables_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "table_participations" (
    "id" TEXT NOT NULL,
    "tableId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "joinedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "leftAt" TIMESTAMP(3),

    CONSTRAINT "table_participations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "buy_ins" (
    "id" TEXT NOT NULL,
    "participationId" TEXT NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "buy_ins_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cash_outs" (
    "id" TEXT NOT NULL,
    "participationId" TEXT NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "cash_outs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "settlements" (
    "id" TEXT NOT NULL,
    "tableId" TEXT NOT NULL,
    "fromUserId" TEXT NOT NULL,
    "toUserId" TEXT NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "pixCopiaECola" TEXT,
    "status" "SettlementStatus" NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "confirmedAt" TIMESTAMP(3),

    CONSTRAINT "settlements_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_firebaseUid_key" ON "users"("firebaseUid");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "tables_ownerId_idx" ON "tables"("ownerId");

-- CreateIndex
CREATE INDEX "tables_status_idx" ON "tables"("status");

-- CreateIndex
CREATE INDEX "table_participations_userId_idx" ON "table_participations"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "table_participations_tableId_userId_key" ON "table_participations"("tableId", "userId");

-- CreateIndex
CREATE INDEX "buy_ins_participationId_idx" ON "buy_ins"("participationId");

-- CreateIndex
CREATE UNIQUE INDEX "cash_outs_participationId_key" ON "cash_outs"("participationId");

-- CreateIndex
CREATE INDEX "settlements_tableId_idx" ON "settlements"("tableId");

-- CreateIndex
CREATE INDEX "settlements_fromUserId_idx" ON "settlements"("fromUserId");

-- CreateIndex
CREATE INDEX "settlements_toUserId_idx" ON "settlements"("toUserId");

-- AddForeignKey
ALTER TABLE "tables" ADD CONSTRAINT "tables_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "table_participations" ADD CONSTRAINT "table_participations_tableId_fkey" FOREIGN KEY ("tableId") REFERENCES "tables"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "table_participations" ADD CONSTRAINT "table_participations_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "buy_ins" ADD CONSTRAINT "buy_ins_participationId_fkey" FOREIGN KEY ("participationId") REFERENCES "table_participations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cash_outs" ADD CONSTRAINT "cash_outs_participationId_fkey" FOREIGN KEY ("participationId") REFERENCES "table_participations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "settlements" ADD CONSTRAINT "settlements_tableId_fkey" FOREIGN KEY ("tableId") REFERENCES "tables"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "settlements" ADD CONSTRAINT "settlements_fromUserId_fkey" FOREIGN KEY ("fromUserId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "settlements" ADD CONSTRAINT "settlements_toUserId_fkey" FOREIGN KEY ("toUserId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
