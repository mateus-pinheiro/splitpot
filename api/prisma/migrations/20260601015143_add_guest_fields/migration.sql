-- DropForeignKey
ALTER TABLE "settlements" DROP CONSTRAINT "settlements_fromUserId_fkey";

-- DropForeignKey
ALTER TABLE "settlements" DROP CONSTRAINT "settlements_toUserId_fkey";

-- AlterTable
ALTER TABLE "settlements" ADD COLUMN     "fromGuestName" TEXT,
ADD COLUMN     "toGuestName" TEXT,
ADD COLUMN     "toPixKey" TEXT,
ALTER COLUMN "fromUserId" DROP NOT NULL,
ALTER COLUMN "toUserId" DROP NOT NULL;

-- AlterTable
ALTER TABLE "table_participations" ADD COLUMN     "guestName" TEXT,
ADD COLUMN     "guestPixKey" TEXT;

-- AddForeignKey
ALTER TABLE "settlements" ADD CONSTRAINT "settlements_fromUserId_fkey" FOREIGN KEY ("fromUserId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "settlements" ADD CONSTRAINT "settlements_toUserId_fkey" FOREIGN KEY ("toUserId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- CHECK: exatamente um identificador (user OU guest) por participação
ALTER TABLE "table_participations"
  ADD CONSTRAINT "table_participations_user_or_guest_chk"
  CHECK (
    ("userId" IS NOT NULL AND "guestName" IS NULL)
    OR ("userId" IS NULL AND "guestName" IS NOT NULL AND "guestPixKey" IS NOT NULL)
  );

-- CHECK: settlement.from e settlement.to são user OU guest (não ambos, não nenhum)
ALTER TABLE "settlements"
  ADD CONSTRAINT "settlements_from_user_or_guest_chk"
  CHECK (
    ("fromUserId" IS NOT NULL AND "fromGuestName" IS NULL)
    OR ("fromUserId" IS NULL AND "fromGuestName" IS NOT NULL)
  );

ALTER TABLE "settlements"
  ADD CONSTRAINT "settlements_to_user_or_guest_chk"
  CHECK (
    ("toUserId" IS NOT NULL AND "toGuestName" IS NULL)
    OR ("toUserId" IS NULL AND "toGuestName" IS NOT NULL)
  );
