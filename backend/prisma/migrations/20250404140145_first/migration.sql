-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "first_name" TEXT,
    "last_name" TEXT,
    "username" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT,
    "role" TEXT NOT NULL DEFAULT 'user',
    "photo" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "email_verified" BOOLEAN NOT NULL DEFAULT false,
    "email_verified_at" TIMESTAMP(3),
    "email_verification_token" TEXT,
    "reset_password_token" TEXT,
    "refresh_token" TEXT,
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "country_code" TEXT,
    "language" TEXT,
    "timezone" TEXT,
    "account_provider" TEXT,
    "social_id" TEXT,
    "github_id" TEXT,
    "github_token" TEXT,
    "google_id" TEXT,
    "google_token" TEXT,
    "sign_in_ip_address" TEXT,
    "ip_address" TEXT,
    "ip_host" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "spot" (
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

    CONSTRAINT "spot_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "category" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "icon" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "category_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "category_spot" (
    "id" TEXT NOT NULL,
    "category_id" TEXT NOT NULL,
    "spot_id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "category_spot_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "photo" (
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

    CONSTRAINT "photo_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "review" (
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

    CONSTRAINT "review_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "like" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "user_id" TEXT NOT NULL,
    "spot_id" TEXT,
    "photo_id" TEXT,

    CONSTRAINT "like_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "save" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "user_id" TEXT NOT NULL,
    "spot_id" TEXT NOT NULL,

    CONSTRAINT "save_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "comment" (
    "id" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "user_id" TEXT NOT NULL,
    "review_id" TEXT NOT NULL,

    CONSTRAINT "comment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "helpful" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "user_id" TEXT NOT NULL,
    "review_id" TEXT NOT NULL,

    CONSTRAINT "helpful_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "nearby_spot" (
    "id" TEXT NOT NULL,
    "distance" DOUBLE PRECISION NOT NULL,
    "travel_time" INTEGER,
    "transport_mode" TEXT,
    "spot_id" TEXT NOT NULL,
    "nearby_spot_id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "nearby_spot_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "travel_plan" (
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

    CONSTRAINT "travel_plan_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "travel_plan_spot" (
    "id" TEXT NOT NULL,
    "day_number" INTEGER,
    "order_number" INTEGER,
    "note" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "travel_plan_id" TEXT NOT NULL,
    "spot_id" TEXT NOT NULL,

    CONSTRAINT "travel_plan_spot_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "search_keyword" (
    "id" TEXT NOT NULL,
    "keyword" TEXT NOT NULL,
    "count" INTEGER NOT NULL DEFAULT 0,
    "is_suggested" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "search_keyword_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_username_key" ON "users"("username");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "category_spot_category_id_spot_id_key" ON "category_spot"("category_id", "spot_id");

-- CreateIndex
CREATE UNIQUE INDEX "like_user_id_spot_id_photo_id_key" ON "like"("user_id", "spot_id", "photo_id");

-- CreateIndex
CREATE UNIQUE INDEX "save_user_id_spot_id_key" ON "save"("user_id", "spot_id");

-- CreateIndex
CREATE UNIQUE INDEX "helpful_user_id_review_id_key" ON "helpful"("user_id", "review_id");

-- CreateIndex
CREATE UNIQUE INDEX "nearby_spot_spot_id_nearby_spot_id_key" ON "nearby_spot"("spot_id", "nearby_spot_id");

-- CreateIndex
CREATE UNIQUE INDEX "travel_plan_spot_travel_plan_id_spot_id_day_number_order_nu_key" ON "travel_plan_spot"("travel_plan_id", "spot_id", "day_number", "order_number");

-- CreateIndex
CREATE UNIQUE INDEX "search_keyword_keyword_key" ON "search_keyword"("keyword");

-- AddForeignKey
ALTER TABLE "spot" ADD CONSTRAINT "spot_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "category_spot" ADD CONSTRAINT "category_spot_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "category"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "category_spot" ADD CONSTRAINT "category_spot_spot_id_fkey" FOREIGN KEY ("spot_id") REFERENCES "spot"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "photo" ADD CONSTRAINT "photo_spot_id_fkey" FOREIGN KEY ("spot_id") REFERENCES "spot"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "photo" ADD CONSTRAINT "photo_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "review" ADD CONSTRAINT "review_spot_id_fkey" FOREIGN KEY ("spot_id") REFERENCES "spot"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "review" ADD CONSTRAINT "review_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "like" ADD CONSTRAINT "like_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "like" ADD CONSTRAINT "like_spot_id_fkey" FOREIGN KEY ("spot_id") REFERENCES "spot"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "like" ADD CONSTRAINT "like_photo_id_fkey" FOREIGN KEY ("photo_id") REFERENCES "photo"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "save" ADD CONSTRAINT "save_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "save" ADD CONSTRAINT "save_spot_id_fkey" FOREIGN KEY ("spot_id") REFERENCES "spot"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "comment" ADD CONSTRAINT "comment_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "comment" ADD CONSTRAINT "comment_review_id_fkey" FOREIGN KEY ("review_id") REFERENCES "review"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "helpful" ADD CONSTRAINT "helpful_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "helpful" ADD CONSTRAINT "helpful_review_id_fkey" FOREIGN KEY ("review_id") REFERENCES "review"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "nearby_spot" ADD CONSTRAINT "nearby_spot_spot_id_fkey" FOREIGN KEY ("spot_id") REFERENCES "spot"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "travel_plan" ADD CONSTRAINT "travel_plan_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "travel_plan_spot" ADD CONSTRAINT "travel_plan_spot_travel_plan_id_fkey" FOREIGN KEY ("travel_plan_id") REFERENCES "travel_plan"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "travel_plan_spot" ADD CONSTRAINT "travel_plan_spot_spot_id_fkey" FOREIGN KEY ("spot_id") REFERENCES "spot"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
