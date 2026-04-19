# Databricks notebook source
# Bronze Layer - Load Banking Transactions Data

from pyspark.sql import SparkSession
from pyspark.sql.functions import *

# Define file paths
csv_path = "/Volumes/workspace/default/banking-transactions-lakehouse-project-selected-dataset-edition/bronze/bank.csv"
delta_path = "/Volumes/workspace/default/banking-transactions-lakehouse-project-selected-dataset-edition/delta/bronze/transactions"

# Read CSV file with schema inference
df_bronze = spark.read \
    .option("header", "true") \
    .option("inferSchema", "true") \
    .csv(csv_path)

print("=" * 50)
print("BRONZE LAYER - RAW DATA LOADED")
print("=" * 50)

# Display first 10 rows
print("\nFirst 10 rows:")
df_bronze.show(10, truncate=False)

# Print original schema
print("\nOriginal Schema:")
df_bronze.printSchema()

# Clean column names for Delta (remove spaces and special characters)
for column in df_bronze.columns:
    new_column = column.strip().replace(" ", "_").replace(",", "").replace(";", "").replace("{", "").replace("}", "").replace("(", "").replace(")", "").replace("\n", "").replace("\t", "").replace("=", "")
    df_bronze = df_bronze.withColumnRenamed(column, new_column)

print("\nCleaned Schema (for Delta):")
df_bronze.printSchema()

# Display row count
row_count = df_bronze.count()
print(f"\nTotal Records: {row_count:,}")

# Save as Delta table
df_bronze.write \
    .format("delta") \
    .mode("overwrite") \
    .save(delta_path)

print(f"\n✓ Data saved to Delta format: {delta_path}")
print("\n✓ Bronze Layer Load Complete!")