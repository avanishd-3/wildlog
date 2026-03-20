import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { db } from "@wildlog/db";
import { park, parkImage } from "@wildlog/db/schema/park";
import { promises } from "fs";

import { env } from "@wildlog/env/server";

export async function seedS3() {
  console.log("Seeding S3...");

  // Do not use us-east-1 as the region, because Garage does not support it. The default region is garage.
  const s3 = new S3Client({
    region: "garage",
    endpoint: env.S3_URL,
    credentials: {
      accessKeyId: env.GARAGE_ACCESS_KEY,
      secretAccessKey: env.GARAGE_SECRET_KEY,
    },
    forcePathStyle: true, // Required for Garage to use path-style URLs -> url/bucket-name/key instead of bucket-name.url/key
  });

  // You need to create the bucket in the web ui and give your key permission to access it.
  // Garage does not support creating buckets via the API
  // It uses a per-bucket, per-key access policy b/c it's much simpler than AWS policy config stuff
  console.log("Beginning S3 seeding...");

  // Delete from parkImages and send delete object request for all objects in the bucket to start with a clean slate
  console.log("Deleting existing park images from S3 and database...");
  const existingParkImages = await db.select().from(parkImage);
  await Promise.all(
    existingParkImages.map(async (parkImage) => {
      try {
        const deleteObjectCommand = new PutObjectCommand({
          Bucket: "park-images",
          Key: `${parkImage.parkId}/${parkImage.imageId}.jpg`,
        });

        await s3.send(deleteObjectCommand);
      } catch (error) {
        console.error(
          `Error deleting image with ID ${parkImage.imageId} for park ID ${parkImage.parkId}:`,
          error,
        );
        // Continue deleting other images even if one fails
      }
    }),
  );
  await db.delete(parkImage);
  console.log("Deleted existing park images from S3 and database");

  // Insert images from .../apps/data/park_images folder into the bucket
  // Also need to insert the image into the parkImages table in the relational database
  const parks = await db
    .select({ id: park.id, publicId: park.publicId, name: park.name })
    .from(park);
  console.log(
    `Found ${parks.length} parks in the database. Starting to seed images for each park...`,
  );

  await Promise.all(
    parks.map(async (park) => {
      const imagePath = `../data/park_images/${park.name}.jpg`; // Relative to apps/server

      try {
        const imageData = await promises.readFile(imagePath);
        // Generate UUID for the image ID
        const imageId = crypto.randomUUID();
        const putObjectCommand = new PutObjectCommand({
          Bucket: "park-images",
          Key: `${park.publicId}/${imageId}.jpg`,
          Body: imageData,
        });
        await s3.send(putObjectCommand);

        // Insert image id into the parkImages table
        await db.insert(parkImage).values({
          imageId: imageId,
          parkId: park.id,
        });
        console.log(`Uploaded image for park '${park.name}' and inserted image idinto database`);
      } catch (error) {
        console.error(`Error uploading image for park '${park.name}':`, error);
        throw new Error(`Error uploading image for park '${park.name}': ${error}`); // So route sends error response if any image fails to upload
      }
    }),
  );

  console.log("S3 seeding complete");
}
