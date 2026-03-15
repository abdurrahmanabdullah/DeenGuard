/*
  Warnings:

  - You are about to drop the `category` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `category_spot` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `comment` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `helpful` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `like` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `nearby_spot` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `photo` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `review` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `save` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `search_keyword` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `spot` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `travel_plan` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `travel_plan_spot` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "category_spot" DROP CONSTRAINT "category_spot_category_id_fkey";

-- DropForeignKey
ALTER TABLE "category_spot" DROP CONSTRAINT "category_spot_spot_id_fkey";

-- DropForeignKey
ALTER TABLE "comment" DROP CONSTRAINT "comment_review_id_fkey";

-- DropForeignKey
ALTER TABLE "comment" DROP CONSTRAINT "comment_user_id_fkey";

-- DropForeignKey
ALTER TABLE "helpful" DROP CONSTRAINT "helpful_review_id_fkey";

-- DropForeignKey
ALTER TABLE "helpful" DROP CONSTRAINT "helpful_user_id_fkey";

-- DropForeignKey
ALTER TABLE "like" DROP CONSTRAINT "like_photo_id_fkey";

-- DropForeignKey
ALTER TABLE "like" DROP CONSTRAINT "like_spot_id_fkey";

-- DropForeignKey
ALTER TABLE "like" DROP CONSTRAINT "like_user_id_fkey";

-- DropForeignKey
ALTER TABLE "nearby_spot" DROP CONSTRAINT "nearby_spot_spot_id_fkey";

-- DropForeignKey
ALTER TABLE "photo" DROP CONSTRAINT "photo_spot_id_fkey";

-- DropForeignKey
ALTER TABLE "photo" DROP CONSTRAINT "photo_user_id_fkey";

-- DropForeignKey
ALTER TABLE "review" DROP CONSTRAINT "review_spot_id_fkey";

-- DropForeignKey
ALTER TABLE "review" DROP CONSTRAINT "review_user_id_fkey";

-- DropForeignKey
ALTER TABLE "save" DROP CONSTRAINT "save_spot_id_fkey";

-- DropForeignKey
ALTER TABLE "save" DROP CONSTRAINT "save_user_id_fkey";

-- DropForeignKey
ALTER TABLE "spot" DROP CONSTRAINT "spot_user_id_fkey";

-- DropForeignKey
ALTER TABLE "travel_plan" DROP CONSTRAINT "travel_plan_user_id_fkey";

-- DropForeignKey
ALTER TABLE "travel_plan_spot" DROP CONSTRAINT "travel_plan_spot_spot_id_fkey";

-- DropForeignKey
ALTER TABLE "travel_plan_spot" DROP CONSTRAINT "travel_plan_spot_travel_plan_id_fkey";

-- DropTable
DROP TABLE "category";

-- DropTable
DROP TABLE "category_spot";

-- DropTable
DROP TABLE "comment";

-- DropTable
DROP TABLE "helpful";

-- DropTable
DROP TABLE "like";

-- DropTable
DROP TABLE "nearby_spot";

-- DropTable
DROP TABLE "photo";

-- DropTable
DROP TABLE "review";

-- DropTable
DROP TABLE "save";

-- DropTable
DROP TABLE "search_keyword";

-- DropTable
DROP TABLE "spot";

-- DropTable
DROP TABLE "travel_plan";

-- DropTable
DROP TABLE "travel_plan_spot";

-- CreateTable
CREATE TABLE "spots" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "address" TEXT,
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "prefecture" TEXT,
    "city" TEXT,
    "website_url" TEXT,
    "phone_number" TEXT,
    "opening_hours" TEXT,
    "closing_days" TEXT,
    "access_info" TEXT,
    "barrier_free_info" TEXT,
    "fee" TEXT,
    "best_season" TEXT,
    "seasonal_notes" TEXT,
    "instagram_url" TEXT,
    "x_url" TEXT,
    "is_verified" BOOLEAN NOT NULL DEFAULT false,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "like_count" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "user_id" TEXT,

    CONSTRAINT "spots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "categories" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "icon" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "categories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "category_spots" (
    "id" TEXT NOT NULL,
    "category_id" TEXT NOT NULL,
    "spot_id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "category_spots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "photos" (
    "id" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "caption" TEXT,
    "width" INTEGER,
    "height" INTEGER,
    "size" INTEGER,
    "file_type" TEXT,
    "taking_date" TIMESTAMP(3),
    "like_count" INTEGER NOT NULL DEFAULT 0,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "is_featured" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "spot_id" TEXT,
    "user_id" TEXT NOT NULL,

    CONSTRAINT "photos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reviews" (
    "id" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "rating" DOUBLE PRECISION NOT NULL,
    "visit_date" TIMESTAMP(3),
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "helpful_count" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "spot_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,

    CONSTRAINT "reviews_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "likes" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "user_id" TEXT NOT NULL,
    "spot_id" TEXT,
    "photo_id" TEXT,

    CONSTRAINT "likes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "saves" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "user_id" TEXT NOT NULL,
    "spot_id" TEXT NOT NULL,

    CONSTRAINT "saves_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "comments" (
    "id" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "user_id" TEXT NOT NULL,
    "review_id" TEXT NOT NULL,

    CONSTRAINT "comments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "helpfuls" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "user_id" TEXT NOT NULL,
    "review_id" TEXT NOT NULL,

    CONSTRAINT "helpfuls_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "nearby_spots" (
    "id" TEXT NOT NULL,
    "distance" DOUBLE PRECISION NOT NULL,
    "travel_time" INTEGER,
    "transport_mode" TEXT,
    "spot_id" TEXT NOT NULL,
    "nearby_spot_id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "nearby_spots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "travel_plans" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "start_date" TIMESTAMP(3),
    "end_date" TIMESTAMP(3),
    "is_public" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "user_id" TEXT NOT NULL,

    CONSTRAINT "travel_plans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "travel_plan_spots" (
    "id" TEXT NOT NULL,
    "day_number" INTEGER,
    "order_number" INTEGER,
    "note" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "travel_plan_id" TEXT NOT NULL,
    "spot_id" TEXT NOT NULL,

    CONSTRAINT "travel_plan_spots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "search_keywords" (
    "id" TEXT NOT NULL,
    "keyword" TEXT NOT NULL,
    "count" INTEGER NOT NULL DEFAULT 0,
    "is_suggested" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "search_keywords_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "category_spots_category_id_spot_id_key" ON "category_spots"("category_id", "spot_id");

-- CreateIndex
CREATE UNIQUE INDEX "likes_user_id_spot_id_photo_id_key" ON "likes"("user_id", "spot_id", "photo_id");

-- CreateIndex
CREATE UNIQUE INDEX "saves_user_id_spot_id_key" ON "saves"("user_id", "spot_id");

-- CreateIndex
CREATE UNIQUE INDEX "helpfuls_user_id_review_id_key" ON "helpfuls"("user_id", "review_id");

-- CreateIndex
CREATE UNIQUE INDEX "nearby_spots_spot_id_nearby_spot_id_key" ON "nearby_spots"("spot_id", "nearby_spot_id");

-- CreateIndex
CREATE UNIQUE INDEX "travel_plan_spots_travel_plan_id_spot_id_day_number_order_n_key" ON "travel_plan_spots"("travel_plan_id", "spot_id", "day_number", "order_number");

-- CreateIndex
CREATE UNIQUE INDEX "search_keywords_keyword_key" ON "search_keywords"("keyword");

-- AddForeignKey
ALTER TABLE "spots" ADD CONSTRAINT "spots_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "category_spots" ADD CONSTRAINT "category_spots_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "category_spots" ADD CONSTRAINT "category_spots_spot_id_fkey" FOREIGN KEY ("spot_id") REFERENCES "spots"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "photos" ADD CONSTRAINT "photos_spot_id_fkey" FOREIGN KEY ("spot_id") REFERENCES "spots"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "photos" ADD CONSTRAINT "photos_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_spot_id_fkey" FOREIGN KEY ("spot_id") REFERENCES "spots"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "likes" ADD CONSTRAINT "likes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "likes" ADD CONSTRAINT "likes_spot_id_fkey" FOREIGN KEY ("spot_id") REFERENCES "spots"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "likes" ADD CONSTRAINT "likes_photo_id_fkey" FOREIGN KEY ("photo_id") REFERENCES "photos"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "saves" ADD CONSTRAINT "saves_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "saves" ADD CONSTRAINT "saves_spot_id_fkey" FOREIGN KEY ("spot_id") REFERENCES "spots"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "comments" ADD CONSTRAINT "comments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "comments" ADD CONSTRAINT "comments_review_id_fkey" FOREIGN KEY ("review_id") REFERENCES "reviews"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "helpfuls" ADD CONSTRAINT "helpfuls_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "helpfuls" ADD CONSTRAINT "helpfuls_review_id_fkey" FOREIGN KEY ("review_id") REFERENCES "reviews"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "nearby_spots" ADD CONSTRAINT "nearby_spots_spot_id_fkey" FOREIGN KEY ("spot_id") REFERENCES "spots"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "travel_plans" ADD CONSTRAINT "travel_plans_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "travel_plan_spots" ADD CONSTRAINT "travel_plan_spots_travel_plan_id_fkey" FOREIGN KEY ("travel_plan_id") REFERENCES "travel_plans"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "travel_plan_spots" ADD CONSTRAINT "travel_plan_spots_spot_id_fkey" FOREIGN KEY ("spot_id") REFERENCES "spots"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
