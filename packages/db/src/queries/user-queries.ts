import { db } from "..";
import { userBucketList, userLike, userReview } from "../schema/user";
import { park } from "../schema";

import { eq, and } from "drizzle-orm";

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

// Check if user has bucket listed a park
export const hasUserBucketListedPark = async (userId: string, parkPublicId: string) => {
  const bucketList = await db
    .select()
    .from(userBucketList)
    .where(and(eq(userBucketList.userId, userId), eq(userBucketList.parkId, park.id)))
    .innerJoin(park, eq(park.publicId, parkPublicId));

  return bucketList.length > 0;
};
