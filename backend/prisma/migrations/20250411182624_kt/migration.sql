/*
  Warnings:

  - You are about to drop the column `github_id` on the `users` table. All the data in the column will be lost.
  - You are about to drop the column `github_token` on the `users` table. All the data in the column will be lost.
  - Added the required column `updated_at` to the `category_spots` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updated_at` to the `helpfuls` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updated_at` to the `likes` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updated_at` to the `saves` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "categories" ADD COLUMN     "deleted_at" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "category_spots" ADD COLUMN     "deleted_at" TIMESTAMP(3),
ADD COLUMN     "updated_at" TIMESTAMP(3) NOT NULL;

-- AlterTable
ALTER TABLE "helpfuls" ADD COLUMN     "deleted_at" TIMESTAMP(3),
ADD COLUMN     "updated_at" TIMESTAMP(3) NOT NULL;

-- AlterTable
ALTER TABLE "likes" ADD COLUMN     "deleted_at" TIMESTAMP(3),
ADD COLUMN     "updated_at" TIMESTAMP(3) NOT NULL;

-- AlterTable
ALTER TABLE "nearby_spots" ADD COLUMN     "deleted_at" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "photos" ADD COLUMN     "credit" TEXT,
ADD COLUMN     "latitude" DOUBLE PRECISION,
ADD COLUMN     "longitude" DOUBLE PRECISION,
ADD COLUMN     "note" TEXT,
ADD COLUMN     "shooting_period" TEXT,
ADD COLUMN     "source_url" TEXT;

-- AlterTable
ALTER TABLE "saves" ADD COLUMN     "deleted_at" TIMESTAMP(3),
ADD COLUMN     "updated_at" TIMESTAMP(3) NOT NULL;

-- AlterTable
ALTER TABLE "search_keywords" ADD COLUMN     "deleted_at" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "spots" ADD COLUMN     "google_map_url" TEXT,
ADD COLUMN     "travelko_url" TEXT;

-- AlterTable
ALTER TABLE "travel_plan_spots" ADD COLUMN     "deleted_at" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "users" DROP COLUMN "github_id",
DROP COLUMN "github_token";
