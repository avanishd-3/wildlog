import polars as pl
import os

# Read the CSV file into a Polars DataFrame
print("cwd is ", os.getcwd())
df = pl.read_csv("park_data_21126_1301.csv")

# Change all column names to lowercase
df = df.rename({col: col.lower() for col in df.columns})

# Calculate summary statistics for the cost column
cost_summary = df["cost"].describe()
print(cost_summary)

# Calculate the number of parks were cost = 0
free_parks_count = df.filter(pl.col("cost") == 0).shape[0]
print(f"Number of free parks: {free_parks_count}")