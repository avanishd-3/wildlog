# graph-db

Neo4J is schema-less, which means there's no code to enforce consistency of node and relationship types. Here they are below.

# Schema

## Nodes

- Parks
  - Attributes: id, publicId, name
- Users
  - Attributes: username

## Relationships

- User can like, want to visit (i.e., in bucket list) park

## Constraints

- Parks have unique id and name