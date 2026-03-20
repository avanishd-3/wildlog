--> statement-breakpoint
CREATE TABLE "user_bucket_list" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "user_bucket_list_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"user_id" text NOT NULL,
	"park_id" integer NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "user_bucket_list_user_id_park_id_unique" UNIQUE("user_id","park_id")
);
--> statement-breakpoint
CREATE TABLE "user_friend" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "user_friend_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"user_id" text NOT NULL,
	"friend_id" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "user_friend_user_id_friend_id_unique" UNIQUE("user_id","friend_id"),
	CONSTRAINT "no_self_friendship" CHECK ("user_friend"."user_id" != "user_friend"."friend_id")
);
--> statement-breakpoint
CREATE TABLE "user_like" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "user_like_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"user_id" text NOT NULL,
	"park_id" integer NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "user_like_user_id_park_id_unique" UNIQUE("user_id","park_id")
);
--> statement-breakpoint
CREATE TABLE "user_list" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "user_list_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"public_id" uuid DEFAULT gen_random_uuid() NOT NULL,
	"user_id" text NOT NULL,
	"name" text NOT NULL,
	"description" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "user_list_public_id_unique" UNIQUE("public_id")
);
--> statement-breakpoint
CREATE TABLE "user_list_item" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "user_list_item_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"user_list_id" integer NOT NULL,
	"park_id" integer NOT NULL,
	"inserted_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "user_list_item_user_list_id_park_id_unique" UNIQUE("user_list_id","park_id")
);
--> statement-breakpoint
CREATE TABLE "user_review" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "user_review_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"public_id" uuid DEFAULT gen_random_uuid() NOT NULL,
	"user_id" text NOT NULL,
	"park_id" integer NOT NULL,
	"rating" numeric NOT NULL,
	"review_text" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"visited_at" timestamp with time zone,
	CONSTRAINT "user_review_public_id_unique" UNIQUE("public_id"),
	CONSTRAINT "user_review_user_id_park_id_unique" UNIQUE("user_id","park_id"),
	CONSTRAINT "rating_check" CHECK ("user_review"."rating" >= 1 AND "user_review"."rating" <= 5),
	CONSTRAINT "rating_point_five_check" CHECK (("user_review"."rating" - FLOOR("user_review"."rating")) IN (0, 0.5))
);
--> statement-breakpoint
ALTER TABLE "user_bucket_list" ADD CONSTRAINT "user_bucket_list_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_bucket_list" ADD CONSTRAINT "user_bucket_list_park_id_park_id_fk" FOREIGN KEY ("park_id") REFERENCES "public"."park"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_friend" ADD CONSTRAINT "user_friend_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_friend" ADD CONSTRAINT "user_friend_friend_id_user_id_fk" FOREIGN KEY ("friend_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_like" ADD CONSTRAINT "user_like_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_like" ADD CONSTRAINT "user_like_park_id_park_id_fk" FOREIGN KEY ("park_id") REFERENCES "public"."park"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_list" ADD CONSTRAINT "user_list_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_list_item" ADD CONSTRAINT "user_list_item_user_list_id_user_list_id_fk" FOREIGN KEY ("user_list_id") REFERENCES "public"."user_list"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_list_item" ADD CONSTRAINT "user_list_item_park_id_park_id_fk" FOREIGN KEY ("park_id") REFERENCES "public"."park"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_review" ADD CONSTRAINT "user_review_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_review" ADD CONSTRAINT "user_review_park_id_park_id_fk" FOREIGN KEY ("park_id") REFERENCES "public"."park"("id") ON DELETE cascade ON UPDATE no action;