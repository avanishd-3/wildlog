-- Custom SQL migration file, put your code below! --
CREATE EXTENSION IF NOT EXISTS pg_trgm;

--> statement-breakpoint

-- gin since we're doing only reads
CREATE INDEX IF NOT EXISTS "description_trigram_idx" ON "park" USING gin ("description" gin_trgm_ops);