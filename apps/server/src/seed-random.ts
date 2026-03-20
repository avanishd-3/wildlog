// Seed users, friends, reviews randomly
// So we can test out Neo4j link prediction stuff

import { db } from "@wildlog/db";
import { park } from "@wildlog/db/schema/park";
import { faker } from "@faker-js/faker";
import { auth } from "@wildlog/auth";
import {
  addFriend,
  bucketListPark,
  likePark,
  mutateReview,
} from "@wildlog/db/mutations/user-mutations";
import { user } from "@wildlog/db/schema/auth";
import { userFriend, userLike } from "@wildlog/db/schema/user";
import { getParkPublicIdsByInternalIds } from "@wildlog/db/queries/park-queries";
import { createUser, deleteAllUsers } from "@wildlog/graph-db/mutations/user";

// --- Config ---
const NUM_USERS = 20;
const FRIENDS_PER_USER = 5;
const REVIEWS_PER_USER = 10;
const LIKES_PER_USER = 10;
const BUCKET_LIST_PER_USER = 10;

// --- Helpers ---
function randomRating() {
  // 1, 1.5, ..., 5
  const steps = [1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5];
  return steps[Math.floor(Math.random() * steps.length)]?.toString() || "5";
}

function randomDateWithinYears(years = 2) {
  const now = new Date();
  const past = new Date(now);
  past.setFullYear(now.getFullYear() - years);
  return new Date(past.getTime() + Math.random() * (now.getTime() - past.getTime()));
}

function sample<T>(arr: T[], n: number): T[] {
  // Randomly sample n unique elements from arr
  const shuffled = arr.slice().sort(() => 0.5 - Math.random());
  return shuffled.slice(0, n);
}

// --- Main part ---
export async function seedTestData() {
  // Clear existing data in Postgres
  await db.delete(user);
  await db.delete(userFriend);
  await db.delete(userLike);

  // Clear existing users in Neo4j
  await deleteAllUsers();

  // Generate users
  let users = [];
  for (let i = 0; i < NUM_USERS; i++) {
    const newUser = {
      name: faker.person.fullName(),
      email: faker.internet.email(),
      username: faker.internet.username(),
    };
    try {
      const data = await auth.api.signUpEmail({
        body: {
          name: newUser.name,
          email: newUser.email,
          password: "password", // So I can remember passwords for logging into different accounts during demo
          username: newUser.username,
        },
      });

      if (!data.user.username || data.user.username === undefined) {
        console.log("Failed to create user during seeding, response data:", data);
        continue; // Keep seeding, to get as many users as possible, even if some fail (they shouldn't fail, but just in case)
      }

      // Create user in Neo4j as well for graph queries
      await createUser(data.user.username);

      users.push(data.user);
    } catch (error) {
      console.log("Error creating user during seeding:", error);
      continue; // Keep seeding, some faker usernames are invalid
    }
  }

  // Load Parks
  const parkRows = await db.select({ id: park.id, publicId: park.publicId }).from(park);
  const parkIds = parkRows.map((p) => p.id);
  const parkPublicIds = parkRows.map((p) => p.publicId);

  // Add some random likes and bucket list additions
  for (const user of users) {
    if (!user.username) {
      console.log("User missing username during seeding");
      continue;
    }
    const likedParks = sample(parkPublicIds, LIKES_PER_USER);

    for (const publicId of likedParks) {
      await likePark(user.id, user.username, publicId);
    }

    for (const publicId of sample(parkPublicIds, BUCKET_LIST_PER_USER)) {
      await bucketListPark(user.id, user.username, publicId);
    }
  }

  // Generate friendships
  const friends = [];
  for (const user of users) {
    if (!user.username) {
      console.log("User missing username during seeding");
      continue;
    }
    const others = users.filter((x) => x.id !== user.id);
    const friendIds = sample(
      others.map((x) => x.id),
      FRIENDS_PER_USER,
    );
    for (const fid of friendIds) {
      const f = {
        // Struct for user + friend info needed
        userId: user.id,
        friendId: fid,
        username: user.username,
        friendUsername: users.find((x) => x.id === fid)?.username || "",
      };
      friends.push(f);
      await addFriend(user.id, fid, f.username, f.friendUsername);
    }
  }

  // Generate Reviews
  for (const user of users) {
    if (!user.username) {
      console.log("User missing username during seeding");
      continue;
    }
    const reviewedParks = sample(parkIds, REVIEWS_PER_USER);
    // Find public IDs for these parks
    const parkPublicIds = await getParkPublicIdsByInternalIds(reviewedParks);
    for (const publicId of parkPublicIds) {
      // Find public
      await mutateReview(
        user.id,
        user.username,
        publicId,
        "",
        randomRating(),
        randomDateWithinYears(),
      );
    }
  }
}
