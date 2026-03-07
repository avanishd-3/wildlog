# Reverse-proxy

Garage does not support the S3 APi endpoint using TLS, so we need to use a reverse proxy for iOS (only allows HTTPS). For simplicity, I've used a Fastify plugin so a Fastify server can act as a reverse proxy. For more robust solutions, use nginx or caddy.

This is a separate server, so the main server doesn't get overwhelemed with requests, which was the reason behind introducing S3 in the first place. This will run in another process, on aother port and should be easy to switch out with a more roubust solution.