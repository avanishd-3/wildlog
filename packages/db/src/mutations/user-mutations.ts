import { db } from "..";
import { user } from "../schema/auth";
import { eq, and } from "drizzle-orm";

import { userLike } from "../schema/user";
import { park } from "../schema";

import { likeIntoGraph, unlikeParkInGraph } from "@wildlog/graph-db/mutations/user";

export const updateUserBio = async (userId: string, bio: string) => {
  await db.update(user).set({ bio }).where(eq(user.id, userId));

  // Return the updated user bio
  return db.select({ bio: user.bio }).from(user).where(eq(user.id, userId));
};

export const updateBaseUserInfo = async (
  userId: string,
  method: "name" | "website" | "both",
  name?: string,
  website?: string,
) => {
  switch (
    method // Errors should never happen b/c of
  ) {
    case "name":
      await db.update(user).set({ name }).where(eq(user.id, userId));
      break;
    case "website":
      await db.update(user).set({ website }).where(eq(user.id, userId));
      break;
    case "both":
      await db.update(user).set({ name, website }).where(eq(user.id, userId));
      break;
  }

  // Return the updated user info
  return db
    .select({ name: user.name, website: user.website })
    .from(user)
    .where(eq(user.id, userId));
};

export const likePark = async (userId: string, username: string, parkPublicId: string) => {
  const parkId = await db.select({ id: park.id }).from(park).where(eq(park.publicId, parkPublicId));

  if (!parkId[0]) {
    // Should not happen
    throw new Error("Park not found");
  }
  await db.insert(userLike).values({ userId: userId, parkId: parkId[0].id });

  // Also need to insert into Neo4j database
  await likeIntoGraph(username, parkPublicId);
};

export const unlikePark = async (userId: string, username: string, parkPublicId: string) => {
  const parkId = await db.select({ id: park.id }).from(park).where(eq(park.publicId, parkPublicId));

  if (!parkId[0]) {
    // Should not happen
    throw new Error("Park not found");
  }
  await db
    .delete(userLike)
    .where(and(eq(userLike.userId, userId), eq(userLike.parkId, parkId[0].id)));

  // Also need to remove from Neo4j database
  await unlikeParkInGraph(username, parkPublicId);
};
