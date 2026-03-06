# s3

Using [Garage](https://garagehq.deuxfleurs.fr/) as an S3-compatible object-store. Configuration specified in garage.toml. See Garage documentation if you want to make any changes.

# Notes

The s3_api endpoint does not support TLS, so we need to use a reverse proxy for the client to be able to access it (since iOS only allows HTTPS requests). Since we're already using Fastify, we can use the http proxy to do this, which is simpler than adding nginx or caddy.