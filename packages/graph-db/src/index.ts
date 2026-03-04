import { env } from "@wildlog/env/server";
import { driver as neo4jDriver, auth } from "neo4j-driver";

// Neo4j architecture requires global driver instance re-used across queries
// Only initialize on first query to avoid driver closed issues
let driver: any = null;

// See: https://neo4j.com/docs/javascript-manual/current/connect/
const graphDb = async () => {
  // URI examples: 'neo4j://localhost', 'neo4j+s://xxx.databases.neo4j.io'
  const URI = env.NEO4J_URL;
  const USER = env.NEO4J_USERNAME;
  const PASSWORD = env.NEO4J_PASSWORD;

  try {
    driver = neo4jDriver(URI, auth.basic(USER, PASSWORD));
    await driver.verifyConnectivity();
    console.log("Neo4j driver connection established");
  } catch (err: any) {
    console.log(`Connection error\n${err}\nCause: ${err.cause}`);
    if (driver === undefined) return;
    await driver.close();
    return;
  }

  return driver; // Use the driver to run queries
};

// Fix issues with driver not being initialized on re-open
// Only use this function in queries
export const graphDBDriver = async () => {
  if (!driver) {
    console.log("Initializing Neo4j driver...");
    driver = await graphDb();
  }
  return driver;
};

export const closeDriver = async () => {
  if (!driver) {
    console.log("No driver to close");
    return;
  }
  try {
    await driver.close();
    driver = null;
    console.log("Driver closed successfully");
  } catch (err: any) {
    console.log(`Error closing driver\n${err}\nCause: ${err.cause}`);
  }
};
