import { db } from "@wildlog/db";
import { computeEmbedding } from "@wildlog/embedding";
import { park, parkEmbedding } from "@wildlog/db/schema/park";

export const seedEmbeddings = async () => {
  // Read from each row in the database, generate an embedding for the description, and write it back to the database.

  // One at a time b/c only 760

  const parks = await db.select().from(park);

  // Get list of descriptions
  const descriptions = parks.map((p) => p.description);

  // Compute embeddings for each description
  const embeddings = await computeEmbedding(descriptions);

  // Update each park with its embedding
  for (let i = 0; i < parks.length; i++) {
    const p = parks[i];

    const embedding = embeddings[i];

    if (p === undefined || embedding === undefined) {
      continue;
    }

    await db.insert(parkEmbedding).values({
      parkId: p.id,
      embedding: embedding,
    });
  }
};
