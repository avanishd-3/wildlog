# Documentation Sources

[Drizzle](https://orm.drizzle.team/)

[Drizzle PostGIS](https://orm.drizzle.team/docs/guides/postgis-geometry-point)

[Some Drizzle best practices](https://gist.github.com/productdevbook/7c9ce3bbeb96b3fabc3c7c2aa2abc717)

# Workflow

If you modify the schema, run 

- `pnpm db:generate`: Generate migration file based on schema changes
- `pnpm run db:migrate`: Apply migrations to database

# Other Scripts

- `pnpm db:stdio`: UI for database (like DBeaver and Supabase)