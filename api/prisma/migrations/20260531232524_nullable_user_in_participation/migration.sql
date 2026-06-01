-- DropForeignKey
ALTER TABLE "table_participations" DROP CONSTRAINT "table_participations_userId_fkey";

-- AlterTable
ALTER TABLE "table_participations" ALTER COLUMN "userId" DROP NOT NULL;

-- AddForeignKey
ALTER TABLE "table_participations" ADD CONSTRAINT "table_participations_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
