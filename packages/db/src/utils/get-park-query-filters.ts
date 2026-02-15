import { park } from "@wildlog/db/schema/park";
import { eq, gte, lt } from "drizzle-orm";

// TODO: Replace any w/ type from GraphQL schema
// Will probably require moving GraphQl schema building to its own package to avoid circular dependency between server and db packages.
export function getParksFilters(filters?: any | null) {
  /**
   * Create array of where clauses based on provided filters. This will be used in the getParksByBoundingBox query to
   * Filter parks based on the provided criteria (and only, or would be too confusing for the user)
   *
   * See: https://brockherion.dev/blog/posts/dynamic-where-statements-in-drizzle/
   */

  // Placeholder condition in case no filters are provided
  const where = [eq(park.id, park.id)];

  if (!filters) {
    return where;
  }

  if (filters?.search) {
    // TODO: Implement search using Levenshtein distance for fuzzy matching
  }

  if (filters?.type) {
    where.push(eq(park.type, filters?.type));
  }

  if (filters?.cost) {
    switch (filters.cost) {
      case "Free":
        where.push(eq(park.free, true));
        break;
      case "Low":
        // 1-14 dollars
        where.push(eq(park.free, false));
        where.push(lt(park.cost, 15));
        break;
      case "Medium":
        // 15-29 dollars
        where.push(gte(park.cost, 15));
        where.push(lt(park.cost, 30));
        break;
      case "High":
        // Above 30 dollars
        where.push(gte(park.cost, 30));
        break;
    }
  }

  return where;
}
