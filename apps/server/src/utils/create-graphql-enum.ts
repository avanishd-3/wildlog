export function createGraphQLEnumFromPgEnum<T extends readonly string[]>(
  // Convert enum values to uppercase and replace spaces with underscores for GraphQL compatibility
  // Have to do this because GraphQL enums cannot have spaces but PostgreSQL enums can
  // Example conversion: "National Park" -> "NATIONAL_PARK"

  builder: PothosSchemaTypes.SchemaBuilder<PothosSchemaTypes.ExtendDefaultTypes<{}>>,
  name: string,
  values: T,
) {
  return builder.enumType(name, {
    values: Object.fromEntries(
      values.map((value) => [value.toUpperCase().replace(/\s+/g, "_"), { value: value }]),
    ),
  });
}
