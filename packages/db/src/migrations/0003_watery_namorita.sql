-- Custom SQL migration file, put your code below! --

-- Index wasn't added before

--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "spatial_index" ON "park" USING gist ("location");