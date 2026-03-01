import { db } from "..";
import { user } from "../schema/auth";
import { eq } from "drizzle-orm";

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
