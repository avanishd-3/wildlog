# Documentation Sources

[Drizzle](https://orm.drizzle.team/)

[Drizzle PostGIS](https://orm.drizzle.team/docs/guides/postgis-geometry-point)

[Some Drizzle best practices](https://gist.github.com/productdevbook/7c9ce3bbeb96b3fabc3c7c2aa2abc717)

# Workflow

If you modify the schema, run 

- `pnpm db:generate`: Generate migration file based on schema changes
- `pnpm run db:migrate`: Apply migrations to database

If you need to write a custom migration file (for things Drizzle does not support), run `npx drizzle-kit generate --custom`

# Other Scripts

- `pnpm db:stdio`: UI for database (like DBeaver and Supabase)

# File Structure

```text
/
├── src
│   ├── migrations (DB migration info)
│   │   └── meta (folder for Drizzle info) -> Drizzle stores the current DB schema as json so generated migration files have proper diffong
│   ├── queries (functions only have SQL select statements)
│   ├── mutations (functions have SQL insert, update, delete statements)
```

# Info not in Drizzle

Unfortunately, Drizzle does not support triggers. See [this pull request](https://github.com/drizzle-team/drizzle-orm/pull/5373) for more information. Even if that PR is merged, it will be merged into Drizzle 1.0, which is a really big update that we will also need to wait for Better Auth to support. So, we may be able to have triggers be in the TS schema in the future, but it will be a while before that happens.

`src/migrations/0008_empty_blue_blade.sql` defines a trigger function abort_tf() that makes any table append-only by automatically cancelling updates and deletes. If you want to make any table append only, see how this file uses abort_tf() to do so for park images.

# Layout

The Postgres DB is the **one** source of truth, with the data being duplicated in the graph DB. This can cause sync issues (especially if the graph DB fails), so in a real app, you'd want to set up a cron job that syncs the relational DB to the graph DB every day (or some other time period, as appropriate).

Since we're just using the graph DB for the two front-page recommendations, small sync issues are also not that big a deal. We also gain a lot of speed from being able to use SQL to fetch likes, bucket list, etc... for user (and count them too).

# JSON parse error

If you run into a JSON parse error, it might be because of a .DS_Store that drizzle kit tries to validate.

[Link for more info](https://stackoverflow.com/questions/79421870/drizzle-kit-generate-syntaxerror-unexpected-token-in-json-at-position-0-on-ma)