import {
  pgTable,
  integer,
  uuid,
  timestamp,
  text,
  unique,
  numeric,
  check,
} from "drizzle-orm/pg-core";
import { park, user } from ".";
import { sql } from "drizzle-orm";

// // Not using composite keys to make joins simpler

// Not used for recommendation (probably need ML for that)
// TODO: Add public/private flag
export const userList = pgTable("user_list", {
  id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
  publicId: uuid("public_id").defaultRandom().notNull().unique(), // For sharing lists without exposing internal IDs
  userId: text("user_id")
    .notNull()
    .references(() => user.id, { onDelete: "cascade" }),
  name: text("name").notNull(),
  description: text("description"),
  createdAt: timestamp("created_at", { mode: "date", withTimezone: true }).defaultNow().notNull(),
});

// No need for public ID here since we only care about the park item
export const userListItem = pgTable(
  "user_list_item",
  {
    id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
    userListId: integer("user_list_id")
      .notNull()
      .references(() => userList.id, { onDelete: "cascade" }),
    parkId: integer("park_id")
      .notNull()
      .references(() => park.id, { onDelete: "cascade" }),
    insertedAt: timestamp("inserted_at", { mode: "date", withTimezone: true })
      .defaultNow()
      .notNull(),
  },
  (t) => [
    unique().on(t.userListId, t.parkId), // A park can only be added once to a list
  ],
);

// Likes and bucket list, same structure but usually likes are for parks they've been to and bucket list is for parks they want to go to
// Also no need for public ID, since these are connected to the park and user

export const userLike = pgTable(
  "user_like",
  {
    id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
    userId: text("user_id")
      .notNull()
      .references(() => user.id, { onDelete: "cascade" }),
    parkId: integer("park_id")
      .notNull()
      .references(() => park.id, { onDelete: "cascade" }),
    createdAt: timestamp("created_at", { mode: "date", withTimezone: true }).defaultNow().notNull(),
  },
  (t) => [
    unique().on(t.userId, t.parkId), // A user can only like a park once
  ],
);

export const userBucketList = pgTable(
  "user_bucket_list",
  {
    id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
    userId: text("user_id")
      .notNull()
      .references(() => user.id, { onDelete: "cascade" }),
    parkId: integer("park_id")
      .notNull()
      .references(() => park.id, { onDelete: "cascade" }),
    createdAt: timestamp("created_at", { mode: "date", withTimezone: true }).defaultNow().notNull(),
  },
  (t) => [
    unique().on(t.userId, t.parkId), // A user can only add a park to their bucket list once
  ],
);

// This is the main thing
// The whole app is about reviews

// I don't think we need to store when they update the review, it's not a good signal for recommendations
export const userReview = pgTable(
  "user_review",
  {
    id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
    publicId: uuid("public_id").defaultRandom().notNull().unique(), // For sharing reviews without exposing internal IDs
    userId: text("user_id")
      .notNull()
      .references(() => user.id, { onDelete: "cascade" }),
    parkId: integer("park_id")
      .notNull()
      .references(() => park.id, { onDelete: "cascade" }),
    rating: numeric("rating").notNull(), // 1-5 stars
    reviewText: text("review_text"),
    createdAt: timestamp("created_at", { mode: "date", withTimezone: true }).defaultNow().notNull(),
    visitedAt: timestamp("visited_at", { mode: "date", withTimezone: true }), // When they visited the park, not when they wrote the review
  },
  (t) => [
    unique().on(t.userId, t.parkId), // A user can only review a park once
    check("rating_check", sql`${t.rating} >= 1 AND ${t.rating} <= 5`), // Rating must be between 1 and 5
    check("rating_point_five_check", sql`(${t.rating} - FLOOR(${t.rating})) IN (0, 0.5)`), // Rating must be in increments of 0.5 (e.g. 1, 1.5, 2, 2.5, etc.)
  ],
);

// User friends
// Don't think we need public ID since we can get the username based on the user ID, and we don't need to share this info externally
export const userFriend = pgTable(
  "user_friend",
  {
    id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
    userId: text("user_id")
      .notNull()
      .references(() => user.id, { onDelete: "cascade" }),
    friendId: text("friend_id")
      .notNull()
      .references(() => user.id, { onDelete: "cascade" }),
    createdAt: timestamp("created_at", { mode: "date", withTimezone: true }).defaultNow().notNull(),
  },
  (t) => [
    unique().on(t.userId, t.friendId), // A user can only be friends with another user once
    check("no_self_friendship", sql`${t.userId} != ${t.friendId}`), // A user cannot be friends with themselves
  ],
);
