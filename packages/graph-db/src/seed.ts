import { graphDBDriver } from ".";

type ParkSimplified = {
  id: number;
  publicId: string;
  name: string;
};

// Need to get list of parks so this doesn't use the relational db
// The relational DB needs to call the graph db to insert likes, bucket list, reviews
// So we need to do this to avoid a circular dependency between the two databases
export const insertParksIntoGraph = async (parksList: ParkSimplified[]) => {
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

    for (const p of parksList) {
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
