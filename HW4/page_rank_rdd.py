import sys
from pyspark import SparkConf, SparkContext

# Initialize Spark Context
conf = SparkConf().setAppName("PageRankRDD").set("spark.default.parallelism", "16")  # Adjust as needed
sc = SparkContext(conf=conf)

# Input and output paths from command-line arguments
input_path = sys.argv[1]
output_path = sys.argv[2]

# Number of partitions (adjust based on your cluster)
num_partitions = 16  # Example: 100 partitions

# Read and parse the input data
lines = sc.textFile(input_path)

# Remove comments
edges = lines.filter(lambda line: not line.startswith("#")) \
    .map(lambda line: line.split('\t')) \
    .map(lambda tokens: (tokens[0], tokens[1]))

# Build the adjacency list: (page, list of outgoing pages)
adjacency_list = edges.groupByKey().mapValues(list) \
    .partitionBy(num_partitions) \
    .cache()

# Initialize ranks: (page, rank)
# Extract all unique pages
pages = edges.flatMap(lambda x: [x[0], x[1]]).distinct()
ranks = pages.map(lambda page: (page, 1.0)) \
    .partitionBy(num_partitions)

# Number of iterations
num_iterations = 10

for i in range(num_iterations):
    print(f"Iteration {i+1}")
    
    # Join adjacency list with ranks
    contributions = adjacency_list.join(ranks) \
        .flatMap(lambda page_neighbors_rank: [
            (neighbor, page_neighbors_rank[1][1] / len(page_neighbors_rank[1][0]))
            for neighbor in page_neighbors_rank[1][0]
        ]) \
        .partitionBy(num_partitions)
    
    # Sum contributions by page
    summed_contributions = contributions.reduceByKey(lambda x, y: x + y) \
        .partitionBy(num_partitions)
    
    # Update ranks with damping factor
    ranks = summed_contributions.mapValues(lambda v: 0.15 + 0.85 * v) \
        .partitionBy(num_partitions)
    

# Save the final ranks to the output path
ranks.map(lambda x: f"{x[0]}\t{x[1]}").saveAsTextFile(output_path)

# Stop the Spark Context
sc.stop()
