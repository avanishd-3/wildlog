-- Custom SQL migration file, put your code below! --

CREATE EXTENSION vector;

--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "park_embedding" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "park_embedding_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"park_id" integer NOT NULL,
	"embedding" vector(384) NOT NULL
);

--> statement-breakpoint
ALTER TABLE "park_embedding" ADD CONSTRAINT "park_embedding_park_id_park_id_fk" FOREIGN KEY ("park_id") REFERENCES "public"."park"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "embeddingIndex" ON "park_embedding" USING hnsw ("embedding" vector_cosine_ops);