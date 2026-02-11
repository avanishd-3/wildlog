import polars as pl
import os

# Read the CSV file into a Polars DataFrame
print("cwd is ", os.getcwd())
df = pl.read_csv("park_data_21126_1301.csv")

# Change all column names to lowercase
df = df.rename({col: col.lower() for col in df.columns})

# Check unique values in the designation column
unique_designations = df["designation"].unique()
print([designation for designation in unique_designations])
print(len(unique_designations))