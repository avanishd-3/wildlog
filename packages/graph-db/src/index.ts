import { env } from "@wildlog/env/server";

// See: https://neo4j.com/docs/javascript-manual/current/connect/
export const graphDb = async () => {
  var neo4j = require("neo4j-driver");

  // URI examples: 'neo4j://localhost', 'neo4j+s://xxx.databases.neo4j.io'
  const URI = env.NEO4J_URL;
  const USER = env.NEO4J_USERNAME;
  const PASSWORD = env.NEO4J_PASSWORD;
  let driver;

  try {
    driver = neo4j.driver(URI, neo4j.auth.basic(USER, PASSWORD));
    await driver.verifyConnectivity();
    console.log("Connection established");
  } catch (err: any) {
    console.log(`Connection error\n${err}\nCause: ${err.cause}`);
    await driver.close();
    return;
  }

  return driver;
  // Use the driver to run queries

  //   await driver.close()
};
