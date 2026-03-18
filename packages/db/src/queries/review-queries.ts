import { db } from "..";
import { park, user } from "../schema";
import { userFriend, userReview } from "../schema/user";

import { desc, eq, inArray, not, or, and } from "drizzle-orm";

// Get user reviews sorted by most recent first, and include the park public ID for each review so we can link to the park page
export const getUserReviews = async (userId: string) => {
  return db
    .select({
      publicId: userReview.publicId,
      parkPublicId: park.publicId,
      parkName: park.name,
      rating: userReview.rating,
      reviewText: userReview.reviewText,
      createdAt: userReview.createdAt,
    })
    .from(userReview)
    .where(eq(userReview.userId, userId))
    .innerJoin(park, eq(park.id, userReview.parkId))
    .orderBy(desc(userReview.createdAt));
};

// Get reviews from friends, sorted by most recent first, and include the park public ID for each review so we can link to the park page
export const getFriendReviews = async (userId: string) => {
  return db
    .select({
      publicId: userReview.publicId,
      parkPublicId: park.publicId,
      parkName: park.name,
      rating: userReview.rating,
      reviewText: userReview.reviewText,
      createdAt: userReview.createdAt,
      friendName: user.name,
    })
    .from(userReview)
    .innerJoin(park, eq(park.id, userReview.parkId))
    .innerJoin(user, eq(user.id, userReview.userId))
    .where(
      and(
        not(eq(userReview.userId, userId)), // Exclude the user's own reviews
        or(
          // Friend in either side of relationship
          inArray(
            userReview.userId,
            db
              .select({ id: userFriend.friendId })
              .from(userFriend)
              .where(eq(userFriend.userId, userId)),
          ),
          inArray(
            userReview.userId,
            db
              .select({ id: userFriend.userId })
              .from(userFriend)
              .where(eq(userFriend.friendId, userId)),
          ),
        ),
      ),
    )
    .orderBy(desc(userReview.createdAt));
};
