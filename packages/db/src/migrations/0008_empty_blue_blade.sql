-- Custom SQL migration file, put your code below! --

CREATE TABLE "park_image" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "park_image_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"park_id" integer NOT NULL,
	"image_id" uuid NOT NULL
);
--> statement-breakpoint
ALTER TABLE "park_image" ADD CONSTRAINT "park_image_park_id_park_id_fk" FOREIGN KEY ("park_id") REFERENCES "public"."park"("id") ON DELETE cascade ON UPDATE no action;

--> statement-breakpoint

-- Make park_image table append only by preventing updates and deletes
-- See: https://stackoverflow.com/questions/74684032/creating-an-append-only-table-in-postgres-using-revoke-on-all-roles-and-granting
create function abort_tf() returns trigger language plpgsql as
$$
begin
  return null;
end;
$$;

CREATE TRIGGER no_update_or_delete_t
BEFORE UPDATE OR DELETE ON park_image 
FOR EACH ROW EXECUTE FUNCTION abort_tf();