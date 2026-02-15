import { park } from "@wildlog/db/schema/park";
import { eq, lte } from "drizzle-orm";

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
    if (filters.cost === "Free") {
      where.push(eq(park.free, true));
    } else {
      switch (filters.cost) {
        case "Low":
          filters.cost = 5;
          break;
        case "Medium":
          filters.cost = 25;
          break;
        case "High":
          filters.cost = 50;
          break;
        default:
          filters.cost = 0; // Default to 0 if cost filter is somehow invalid, though this should be prevented by GraphQL enum validation
      }
      where.push(lte(park.cost, filters.cost)); // Park cost <= filter cost
    }
  }

  return where;
}
