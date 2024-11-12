from pyspark.sql import SparkSession
from pyspark.sql.functions import explode, split, col

# init
spark = SparkSession.builder \
    .appName("Word Count") \
    .getOrCreate()

import sys
input_path = sys.argv[1]
output_path = sys.argv[2]

# read text
text_df = spark.read.text(input_path)

# split words
words_df = text_df.select(split(col("value"), "\\s+").alias("words"))

# explode words
exploded_words_df = words_df.select(explode(col("words")).alias("word"))

# count words
word_counts = exploded_words_df.groupBy("word").count()

# write to csv
word_counts.write.csv(output_path, header=True)

spark.stop()
