import { db } from "..";
import { user } from "../schema/auth";
import { eq } from "drizzle-orm";

export const updateUserBio = async (userId: string, bio: string) => {
  await db.update(user).set({ bio }).where(eq(user.id, userId));

  // Return the updated user bio
  return db.select({ bio: user.bio }).from(user).where(eq(user.id, userId));
};
