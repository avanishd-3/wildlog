import { graphDBDriver } from "..";

export const createUser = async (username: string) => {
  const driver = await graphDBDriver();
  const session = driver.session({ database: process.env.NEO4J_DATABASE });
  try {
    // Create user constraints
    await session.run(
      "CREATE CONSTRAINT user_id_unique IF NOT EXISTS FOR (u:User) REQUIRE u.id IS UNIQUE",
    );
    await session.run(
      "CREATE CONSTRAINT user_username_unique IF NOT EXISTS FOR (u:User) REQUIRE u.username IS UNIQUE",
    );

    // Insert user into graph DB
    await session.run("CREATE (u:User {username: $username})", {
      username,
    });
  } finally {
    await session.close();
  }
};

export const deleteUser = async (username: string) => {
  const driver = await graphDBDriver();
  const session = driver.session({ database: process.env.NEO4J_DATABASE });
  try {
    // Delete user from graph DB
    // Detach delete removes all their relationships as well
    await session.run("MATCH (u:User {username: $username}) DETACH DELETE u", {
      username,
    });
  } finally {
    await session.close();
  }
};

// ---- Relationship mutations ----

export const likeIntoGraph = async (username: string, parkPublicId: string) => {
  const driver = await graphDBDriver();
  const session = driver.session({ database: process.env.NEO4J_DATABASE });

  // Create a LIKES relationship between the user and park
  // Use merge to prevent duplicates
  try {
    console.log(
      `Creating LIKES relationship in graph DB for user ${username} and park ${parkPublicId}`,
    );
    await session.run(
      "MATCH (u:User {username: $username}), (p:Park {publicId: $parkPublicId}) MERGE (u)-[:LIKES]->(p)",
      {
        username,
        parkPublicId,
      },
    );
  } finally {
    await session.close();
  }
};

export const unlikeParkInGraph = async (username: string, parkPublicId: string) => {
  const driver = await graphDBDriver();
  const session = driver.session({ database: process.env.NEO4J_DATABASE });

  // Delete the LIKES relationship between the user and park
  try {
    console.log(
      `Deleting LIKES relationship in graph DB for user ${username} and park ${parkPublicId}`,
    );
    await session.run(
      "MATCH (u:User {username: $username})-[r:LIKES]->(p:Park {publicId: $parkPublicId}) DELETE r",
      {
        username,
        parkPublicId,
      },
    );
  } finally {
    await session.close();
  }
};
