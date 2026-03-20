import { builder } from "@/builder";
import { getFriendReviews, getUserReviews } from "@wildlog/db/queries/review-queries";

// TODO: Use pagination instead

// More detailed review than what is fetched for the park detail page
// This is for the reviews tab
const reviewDetailed = builder.simpleObject("ReviewDetailed", {
  fields: (t) => ({
    id: t.string({
      nullable: false,
    }), // This is the publicId from the database, which is a UUID string
    authorName: t.string({
      nullable: false,
    }),
    reviewText: t.string({
      nullable: true,
    }),
    rating: t.string({
      nullable: false,
    }),
    parkName: t.string({
      nullable: false,
    }),
    visitedDate: t.string({
      nullable: false,
    }),
  }),
});

builder.queryField("meReviews", (t) =>
  t.field({
    type: [reviewDetailed],
    authScopes: {
      loggedIn: true,
    },
    resolve: async (_, __, context) => {
      if (!context.user?.id) {
        throw new Error("User not authenticated"); // This should never happen due to authScopes, but just to satisfy TypeScript
      }

      const reviews = await getUserReviews(context.user.id);
      return reviews.map((review) => ({
        id: review.publicId,
        authorName: "You", // User doesn't need to see their own name
        reviewText: review.reviewText,
        rating: review.rating,
        parkName: review.parkName,
        visitedDate: review.createdAt.toISOString(), // Convert Date to ISO string for easier handling on the client
      }));
    },
  }),
);

builder.queryField("friendReviews", (t) =>
  t.field({
    type: [reviewDetailed],
    authScopes: {
      loggedIn: true,
    },
    resolve: async (_, __, context) => {
      if (!context.user?.id) {
        throw new Error("User not authenticated"); // This should never happen due to authScopes, but just to satisfy TypeScript
      }

      const reviews = await getFriendReviews(context.user.id);
      return reviews.map((review) => ({
        id: review.publicId,
        authorName: review.friendName,
        reviewText: review.reviewText,
        rating: review.rating,
        parkName: review.parkName,
        visitedDate: review.createdAt.toISOString(), // Convert Date to ISO string for easier handling on the client
      }));
    },
  }),
);
