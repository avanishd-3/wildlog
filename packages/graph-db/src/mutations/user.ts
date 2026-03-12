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
// IMPORTANT: Need to lowercase public id b/c Neo4j is case sensitive and GraphQL returns all caps

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
        parkPublicId: parkPublicId.toLowerCase(),
      },
    );
  } finally {
    await session.close();
  }
};

export const bucketListIntoGraph = async (username: string, parkPublicId: string) => {
  const driver = await graphDBDriver();
  const session = driver.session({ database: process.env.NEO4J_DATABASE });

  // Create a WANTS_TO_VISIT relationship between the user and park
  // Use merge to prevent duplicates
  try {
    console.log(
      `Creating WANTS_TO_VISIT relationship in graph DB for user ${username} and park ${parkPublicId}`,
    );
    await session.run(
      "MATCH (u:User {username: $username}), (p:Park {publicId: $parkPublicId}) MERGE (u)-[:WANTS_TO_VISIT]->(p)",
      {
        username,
        parkPublicId: parkPublicId.toLowerCase(),
      },
    );
  } finally {
    await session.close();
  }
};

export const visitedParkIntoGraph = async (
  username: string,
  parkPublicId: string,
  visitedAt: Date,
) => {
  const driver = await graphDBDriver();
  const session = driver.session({ database: process.env.NEO4J_DATABASE });

  // Create a VISITED relationship between the user and park with visitedAt property
  try {
    console.log(
      `Creating VISITED relationship in graph DB for user ${username} and park ${parkPublicId} with visitedAt ${visitedAt}`,
    );
    await session.run(
      "MATCH (u:User {username: $username}), (p:Park {publicId: $parkPublicId}) MERGE (u)-[r:VISITED]->(p) SET r.visitedAt = $visitedAt",
      {
        username,
        parkPublicId: parkPublicId.toLowerCase(),
        visitedAt: visitedAt.toISOString(),
      },
    );
  } finally {
    await session.close();
  }
};

export const insertRatedHighlyInGraph = async (username: string, parkPublicId: string) => {
  const driver = await graphDBDriver();
  const session = driver.session({ database: process.env.NEO4J_DATABASE });

  // Create a RATED_HIGHLY relationship between the user and park
  // Use merge to prevent duplicates
  try {
    console.log(
      `Creating RATED_HIGHLY relationship in graph DB for user ${username} and park ${parkPublicId}`,
    );
    await session.run(
      "MATCH (u:User {username: $username}), (p:Park {publicId: $parkPublicId}) MERGE (u)-[h:RATED_HIGHLY]->(p) SET h.ratedAt = datetime()",
      {
        username,
        parkPublicId: parkPublicId.toLowerCase(),
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
        parkPublicId: parkPublicId.toLowerCase(),
      },
    );
  } finally {
    await session.close();
  }
};

export const removeFromBucketListInGraph = async (username: string, parkPublicId: string) => {
  const driver = await graphDBDriver();
  const session = driver.session({ database: process.env.NEO4J_DATABASE });

  // Delete the WANTS_TO_VISIT relationship between the user and park
  try {
    console.log(
      `Deleting WANTS_TO_VISIT relationship in graph DB for user ${username} and park ${parkPublicId}`,
    );
    await session.run(
      "MATCH (u:User {username: $username})-[r:WANTS_TO_VISIT]->(p:Park {publicId: $parkPublicId}) DELETE r",
      {
        username,
        parkPublicId: parkPublicId.toLowerCase(),
      },
    );
  } finally {
    await session.close();
  }
};

export const removeRatedHighlyInGraph = async (username: string, parkPublicId: string) => {
  const driver = await graphDBDriver();
  const session = driver.session({ database: process.env.NEO4J_DATABASE });

  // Delete the RATED_HIGHLY relationship between the user and park
  try {
    console.log(
      `Deleting RATED_HIGHLY relationship in graph DB for user ${username} and park ${parkPublicId}`,
    );
    await session.run(
      "MATCH (u:User {username: $username})-[r:RATED_HIGHLY]->(p:Park {publicId: $parkPublicId}) DELETE r",
      {
        username,
        parkPublicId: parkPublicId.toLowerCase(),
      },
    );
  } finally {
    await session.close();
  }
};
