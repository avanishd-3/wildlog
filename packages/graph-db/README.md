# graph-db

Neo4J is schema-less, which means there's no code to enforce consistency of node and relationship types. Here they are below.

# Schema

## Nodes

- Parks
  - Attributes: id, publicId, name
- Users
  - Attributes: username

## Relationships

All relationships are from user to user or user to park. Park does not have any outgoing edges.

- User to park:
  - Like
  - Wants to visit
  - Visited (attribute at: )

## Constraints

- Parks have unique id and name