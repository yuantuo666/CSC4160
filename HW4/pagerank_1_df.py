import sys
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, lit, sum as sql_sum

spark = SparkSession.builder.appName("PageRank").getOrCreate()

input_path = sys.argv[1]
output_path = sys.argv[2]

# read data
edges_df = spark.read.csv(
    input_path,
    sep='\t',
    inferSchema=True,
    comment='#',
    header=True
).toDF("from", "to")

# collect all page and init rank
ranks_df = edges_df.select(col("from").alias("page")) \
    .union(edges_df.select(col("to").alias("page"))).distinct() \
    .withColumn("rank", lit(1.0))

# calculate number of outgoing links for each page
outgoing_links_df = edges_df.groupBy("from").count().withColumnRenamed("count", "num_outgoing_links")

# run 10 iterations
for i in range(10):
    # each page p contributes to its outgoing neighbors a value of rank(p)/(# of outgoing neighbors of p).

    # first join outgoing_links_df and current ranks_df on "from" & "page" column
    # then calculate the contribution = rank / num_outgoing_links
    total_rank_df = outgoing_links_df.join(ranks_df, outgoing_links_df["from"] == ranks_df["page"]) \
        .select("from", (col("rank") / col("num_outgoing_links")).alias("contribution"))
    
    # for each edge, assign the contribution according to "from" page
    # then sum up the contribution for "to" page
    contributions_df = edges_df.join(total_rank_df, "from") \
        .groupBy("to").agg(sql_sum("contribution").alias("sum_contribution"))

    # rename "to", then update page rank according to the formula
    # here use "lit" to generate a constant col
    ranks_df = contributions_df \
        .withColumn("page", col("to")) \
        .withColumn("rank", lit(0.15) + 0.85 * col("sum_contribution")) \
        .select("page", "rank")

# save result
ranks_df.write.csv(output_path, header=True)

# stop
spark.stop()

