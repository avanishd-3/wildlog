import { graphDBDriver } from ".";
import { db } from "@wildlog/db";
import { park } from "@wildlog/db/schema/park";

export const insertParksIntoGraph = async () => {
  const driver = await graphDBDriver();
  const session = driver.session({ database: process.env.NEO4J_DATABASE });
  try {
    // Create park node constraints
    await session.run(
      "CREATE CONSTRAINT park_id_unique IF NOT EXISTS FOR (p:Park) REQUIRE p.id IS UNIQUE",
    );
    await session.run(
      "CREATE CONSTRAINT park_name_unique IF NOT EXISTS FOR (p:Park) REQUIRE p.name IS UNIQUE",
    );

    // Delete existing park nodes and relationships to avoid duplicates when seeding multiple times
    await session.run("MATCH (p:Park) DETACH DELETE p");

    // Insert parks into graph DB

    const parks = await db.select().from(park);

    for (const p of parks) {
      await session.run("CREATE (p:Park {id: $id, publicId: $publicId, name: $name})", {
        id: p.id,
        publicId: p.publicId,
        name: p.name,
      });
    }
  } finally {
    await session.close();
  }
};
