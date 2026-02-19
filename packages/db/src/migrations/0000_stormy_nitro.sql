-- Custom SQL migration file, put your code below! --

CREATE EXTENSION postgis;

--> statement-breakpoint
CREATE TYPE "public"."park_designation" AS ENUM('National Seashore', 'National Trail', 'State Vehicular Recreation Area', 'National Historic Site', 'National Military Park', 'National River', 'State Natural Reserve', 'National Parkway', 'State Marine Reserve', 'Memorial', 'National Park', 'Park Property', 'National Military Park Site', 'National Recreation Area', 'National Lakeshore', 'State Historic Site', 'State Historic Park', 'State Park', 'National Historic Park', 'National Reserve', 'State Beach', 'National Historical Park', 'Point of Interest', 'National Preserve', 'National Memorial', 'State Recreation Area', 'National Monument');--> statement-breakpoint
CREATE TYPE "public"."park_type" AS ENUM('National', 'State');--> statement-breakpoint

--> statement-breakpoint
CREATE TABLE "park" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "park_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"public_id" uuid DEFAULT gen_random_uuid() NOT NULL,
	"name" text NOT NULL,
	"description" text NOT NULL,
	"designation" "park_designation" NOT NULL,
	"location" geometry(point) NOT NULL,
	"states" text NOT NULL,
	"type" "park_type" NOT NULL,
	"cost" integer NOT NULL,
	"free" boolean GENERATED ALWAYS AS ("park"."cost" = 0) STORED NOT NULL,
	CONSTRAINT "park_public_id_unique" UNIQUE("public_id")
);