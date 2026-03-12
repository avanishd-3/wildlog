import { db } from "..";
import { user } from "../schema/auth";
import { eq, and } from "drizzle-orm";

import { userBucketList, userLike, userReview } from "../schema/user";
import { park } from "../schema";

import {
  bucketListIntoGraph,
  insertRatedHighlyInGraph,
  likeIntoGraph,
  removeFromBucketListInGraph,
  removeRatedHighlyInGraph,
  unlikeParkInGraph,
  visitedParkIntoGraph,
} from "@wildlog/graph-db/mutations/user";

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

export const mutateReview = async (
  userId: string,
  username: string,
  parkPublicId: string,
  review: string,
  newRating: string,
  visitedAt: Date,
) => {
  const parkId = await db.select({ id: park.id }).from(park).where(eq(park.publicId, parkPublicId));

  if (parkId.length === 0 || !parkId[0]) {
    // Should not happen
    throw new Error("Park not found");
  }

  const reviewExists = await db
    .select()
    .from(userReview)
    .where(and(eq(userReview.userId, userId), eq(userReview.parkId, parkId[0].id)));

  if (reviewExists.length > 0 && reviewExists[0]) {
    // Update park review
    console.log("Review already exists, updating review");
    await db
      .update(userReview)
      .set({ reviewText: review, rating: newRating, visitedAt: visitedAt })
      .where(and(eq(userReview.userId, userId), eq(userReview.parkId, parkId[0].id)));

    // If new rating is 4.0 or higher and old rating is lower than 4.0, add rated highly relationship in Neo4j database
    if (parseFloat(newRating) >= 4.0 && parseFloat(reviewExists[0].rating) < 4.0) {
      console.log(
        "New rating is 4.0 or higher and old rating is lower than 4.0, adding RATED_HIGHLY relationship in graph DB",
      );
      return await insertRatedHighlyInGraph(username, parkPublicId);
    }
    // If new rating is lower than 4.0 and old rating is 4.0 or higher, remove rated highly relationship in Neo4j database
    else if (parseFloat(newRating) < 4.0 && parseFloat(reviewExists[0].rating) >= 4.0) {
      console.log(
        "New rating is lower than 4.0 and old rating is 4.0 or higher, removing RATED_HIGHLY relationship in graph DB",
      );
      return await removeRatedHighlyInGraph(username, parkPublicId);
    }
  } else {
    console.log("Review does not exist, creating new review");
    // Insert new park review with default rating of 0 (user can update rating later)
    await db
      .insert(userReview)
      .values({
        userId: userId,
        parkId: parkId[0].id,
        rating: newRating,
        reviewText: review,
        visitedAt: visitedAt,
      });

    // Insert visited at in Neo4j database
    await visitedParkIntoGraph(username, parkPublicId, visitedAt);

    // If new rating is 4.0 or higher and old rating is lower than 4.0, add rated highly relationship in Neo4j database
    if (parseFloat(newRating) >= 4.0) {
      console.log("New rating is 4.0 or higher, adding RATED_HIGHLY relationship in graph DB");
      return await insertRatedHighlyInGraph(username, parkPublicId);
    } else {
      console.log("New rating is lower than 4.0, not adding RATED_HIGHLY relationship in graph DB");
      return;
    }
  }
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

export const bucketListPark = async (userId: string, username: string, parkPublicId: string) => {
  const parkId = await db.select({ id: park.id }).from(park).where(eq(park.publicId, parkPublicId));

  if (!parkId[0]) {
    // Should not happen
    throw new Error("Park not found");
  }
  await db.insert(userBucketList).values({ userId: userId, parkId: parkId[0].id });

  // Also need to insert into Neo4j database
  await bucketListIntoGraph(username, parkPublicId);
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

export const removeParkFromBucketList = async (
  userId: string,
  username: string,
  parkPublicId: string,
) => {
  const parkId = await db.select({ id: park.id }).from(park).where(eq(park.publicId, parkPublicId));

  if (!parkId[0]) {
    // Should not happen
    throw new Error("Park not found");
  }
  await db
    .delete(userBucketList)
    .where(and(eq(userBucketList.userId, userId), eq(userBucketList.parkId, parkId[0].id)));

  // Also need to remove from Neo4j database

  await removeFromBucketListInGraph(username, parkPublicId);
};
