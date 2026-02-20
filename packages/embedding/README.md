# Embeddings

Currently using all-MiniLM-L6-v2 because it is 23 million parameters, so it should have low latency.

**Important**: If you change the embedding model, you need to re-embed the text in the database. The model that embeds the user query and the models that embedded the park descriptions needs to be identical, or the performance will be pretty bad. 