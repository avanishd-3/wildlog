import { db } from "..";
import { userBucketList, userLike, userReview } from "../schema/user";
import { park, parkImage } from "../schema";

import { eq, and, sql } from "drizzle-orm";

// Get user review for a specific park, if it exists
export const getUserReview = async (userId: string, parkPublicId: string) => {
  const review = await db
    .select({
      review: userReview.reviewText,
      rating: userReview.rating,
      visitedAt: userReview.visitedAt,
    })
    .from(userReview)
    .where(and(eq(userReview.userId, userId), eq(userReview.parkId, park.id)))
    .innerJoin(park, eq(park.publicId, parkPublicId));

  return review.length > 0 ? review[0] : null;
};

// Check if user has liked a park
export const hasUserLikedPark = async (userId: string, parkPublicId: string) => {
  const like = await db
    .select()
    .from(userLike)
    .where(and(eq(userLike.userId, userId), eq(userLike.parkId, park.id)))
    .innerJoin(park, eq(park.publicId, parkPublicId));

  return like.length > 0;
};

// Get all parks that a user has liked
export const getUserLikedParks = async (userId: string) => {
  return db
    .select({
      publicId: park.publicId,
      name: park.name,
      description: park.description,
      designation: park.designation,
      states: park.states,
      type: park.type,
      cost: park.cost,
      free: park.free,
      latitude: sql`ST_Y(${park.location})`,
      longitude: sql`ST_X(${park.location})`,
      imageId: parkImage.imageId,
    })
    .from(userLike)
    .where(eq(userLike.userId, userId))
    .innerJoin(park, eq(park.id, userLike.parkId))
    .innerJoin(parkImage, eq(parkImage.parkId, park.id)); // Join with parkImage to get image data for each liked park
};

// Get all parks that a user has bucket listed
export const getUserBucketListedParks = async (userId: string) => {
  return db
    .select({
      publicId: park.publicId,
      name: park.name,
      description: park.description,
      designation: park.designation,
      states: park.states,
      type: park.type,
      cost: park.cost,
      free: park.free,
      latitude: sql`ST_Y(${park.location})`,
      longitude: sql`ST_X(${park.location})`,
      imageId: parkImage.imageId,
    })
    .from(userBucketList)
    .where(eq(userBucketList.userId, userId))
    .innerJoin(park, eq(park.id, userBucketList.parkId))
    .innerJoin(parkImage, eq(parkImage.parkId, park.id)); // Join with parkImage to get image data for each bucket listed park
};

// Check if user has bucket listed a park
export const hasUserBucketListedPark = async (userId: string, parkPublicId: string) => {
  const bucketList = await db
    .select()
    .from(userBucketList)
    .where(and(eq(userBucketList.userId, userId), eq(userBucketList.parkId, park.id)))
    .innerJoin(park, eq(park.publicId, parkPublicId));

  return bucketList.length > 0;
};
