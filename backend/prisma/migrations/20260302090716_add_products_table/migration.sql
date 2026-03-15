/*
  Warnings:

  - You are about to drop the column `email_verification_token` on the `users` table. All the data in the column will be lost.
  - You are about to drop the column `email_verified` on the `users` table. All the data in the column will be lost.
  - You are about to drop the column `email_verified_at` on the `users` table. All the data in the column will be lost.
  - You are about to drop the column `refresh_token` on the `users` table. All the data in the column will be lost.
  - You are about to drop the column `reset_password_token` on the `users` table. All the data in the column will be lost.
  - You are about to drop the `categories` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `category_spots` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `comments` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `helpfuls` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `likes` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `nearby_spots` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `photos` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `reviews` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `saves` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `search_keywords` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `spots` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `travel_plan_spots` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `travel_plans` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "category_spots" DROP CONSTRAINT "category_spots_category_id_fkey";

-- DropForeignKey
ALTER TABLE "category_spots" DROP CONSTRAINT "category_spots_spot_id_fkey";

-- DropForeignKey
ALTER TABLE "comments" DROP CONSTRAINT "comments_review_id_fkey";

-- DropForeignKey
ALTER TABLE "comments" DROP CONSTRAINT "comments_user_id_fkey";

-- DropForeignKey
ALTER TABLE "helpfuls" DROP CONSTRAINT "helpfuls_review_id_fkey";

-- DropForeignKey
ALTER TABLE "helpfuls" DROP CONSTRAINT "helpfuls_user_id_fkey";

-- DropForeignKey
ALTER TABLE "likes" DROP CONSTRAINT "likes_photo_id_fkey";

-- DropForeignKey
ALTER TABLE "likes" DROP CONSTRAINT "likes_spot_id_fkey";

-- DropForeignKey
ALTER TABLE "likes" DROP CONSTRAINT "likes_user_id_fkey";

-- DropForeignKey
ALTER TABLE "nearby_spots" DROP CONSTRAINT "nearby_spots_spot_id_fkey";

-- DropForeignKey
ALTER TABLE "photos" DROP CONSTRAINT "photos_spot_id_fkey";

-- DropForeignKey
ALTER TABLE "photos" DROP CONSTRAINT "photos_user_id_fkey";

-- DropForeignKey
ALTER TABLE "reviews" DROP CONSTRAINT "reviews_spot_id_fkey";

-- DropForeignKey
ALTER TABLE "reviews" DROP CONSTRAINT "reviews_user_id_fkey";

-- DropForeignKey
ALTER TABLE "saves" DROP CONSTRAINT "saves_spot_id_fkey";

-- DropForeignKey
ALTER TABLE "saves" DROP CONSTRAINT "saves_user_id_fkey";

-- DropForeignKey
ALTER TABLE "spots" DROP CONSTRAINT "spots_user_id_fkey";

-- DropForeignKey
ALTER TABLE "travel_plan_spots" DROP CONSTRAINT "travel_plan_spots_spot_id_fkey";

-- DropForeignKey
ALTER TABLE "travel_plan_spots" DROP CONSTRAINT "travel_plan_spots_travel_plan_id_fkey";

-- DropForeignKey
ALTER TABLE "travel_plans" DROP CONSTRAINT "travel_plans_user_id_fkey";

-- AlterTable
ALTER TABLE "users" DROP COLUMN "email_verification_token",
DROP COLUMN "email_verified",
DROP COLUMN "email_verified_at",
DROP COLUMN "refresh_token",
DROP COLUMN "reset_password_token",
ADD COLUMN     "bio" TEXT;

-- DropTable
DROP TABLE "categories";

-- DropTable
DROP TABLE "category_spots";

-- DropTable
DROP TABLE "comments";

-- DropTable
DROP TABLE "helpfuls";

-- DropTable
DROP TABLE "likes";

-- DropTable
DROP TABLE "nearby_spots";

-- DropTable
DROP TABLE "photos";

-- DropTable
DROP TABLE "reviews";

-- DropTable
DROP TABLE "saves";

-- DropTable
DROP TABLE "search_keywords";

-- DropTable
DROP TABLE "spots";

-- DropTable
DROP TABLE "travel_plan_spots";

-- DropTable
DROP TABLE "travel_plans";

-- CreateTable
CREATE TABLE "products" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "details" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "products_pkey" PRIMARY KEY ("id")
);
