from pyspark import pipelines as dp
from pyspark.sql.functions import *

@dp.table(
    comment="Bronze layer - raw banking transactions from CSV",
    table_properties={"quality": "bronze"}
)
def bronze_transactions():
    """
    Load raw banking transactions from CSV using Auto Loader.
    Auto Loader provides schema inference and evolution.
    """
    csv_path = "/Volumes/workspace/default/banking-transactions-lakehouse-project-selected-dataset-edition/bronze/bank.csv"
    
    df = (spark.readStream
        .format("cloudFiles")
        .option("cloudFiles.format", "csv")
        .option("cloudFiles.schemaLocation", "/Volumes/workspace/default/banking-transactions-lakehouse-project-selected-dataset-edition/schemas/bronze")
        .option("header", "true")
        .option("inferSchema", "true")
        .load(csv_path)
    )
    
    # Clean column names for Delta
    for column in df.columns:
        new_column = (column.strip()
            .replace(" ", "_")
            .replace(",", "")
            .replace(";", "")
            .replace("{", "")
            .replace("}", "")
            .replace("(", "")
            .replace(")", "")
            .replace("\n", "")
            .replace("\t", "")
            .replace("=", "")
        )
        df = df.withColumnRenamed(column, new_column)
    
    return df
