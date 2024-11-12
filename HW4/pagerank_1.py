import sys
from pyspark import SparkContext, SparkConf 

conf = SparkConf().setAppName("PageRankRDD")
spark = SparkContext(conf=conf)

input_path = sys.argv[1]
output_path = sys.argv[2]

# read data
lines = spark.textFile(input_path)

# loading edge
edges_rdd = lines.filter(lambda line: not line.startswith("#")) \
    .map(lambda line: line.split('\t')) \
    .map(lambda tokens: (tokens[0], tokens[1])) \
    .groupByKey() \
    .cache()

ranks_rdd = edges_rdd.map(lambda x: (x[0], 1.0))

for i in range(10):
    # change "to" as the key here
    contributions_rdd = edges_rdd.join(ranks_rdd).flatMap(
        lambda x: [(to, x[1][1] / len(x[1][0])) for to in x[1][0]]
    )
    # calculate the contribution
    ranks_rdd = contributions_rdd.reduceByKey(lambda x, y: x + y).map(lambda x: (x[0], 0.15 + x[1] * 0.85))

ranks_rdd.saveAsTextFile(output_path)
