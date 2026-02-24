# Extend the official PostGIS image to include pgvector for storing embeddings
FROM postgis/postgis:18-3.6-alpine

WORKDIR /app

# pgvector needs clang and llvm 19 or higher

RUN apk add --no-cache git
RUN apk add --no-cache build-base
RUN apk add --no-cache clang19
RUN apk add --no-cache llvm19-dev

RUN git clone --branch v0.8.1 https://github.com/pgvector/pgvector.git

WORKDIR /app/pgvector

RUN make
RUN make install

# Clean up build dependencies to reduce image size
RUN apk del --no-cache build-base clang19 llvm19-dev git