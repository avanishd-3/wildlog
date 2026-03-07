# env

This package just provides Zod validation for apps/server when it starts. When you run the server, if you're missing any of the required env files, the server will fail immediately.

If you run another Fastify instance (like reverse-proxy does), this make that server fail. To handle this, I used dotenv to read directly from the apps/server env variable.