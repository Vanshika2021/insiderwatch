"""InsiderWatch shared settings."""

START_YEAR = 2015
END_YEAR = 2025

HDFS_HOME = "/user/va2652_nyu_edu"
HDFS_RAW = f"{HDFS_HOME}/insider/raw"

# Cluster: Spark 3.5.3 / Scala 2.12
SPARK_VERSION = "3.5.3"
SCALA_VERSION = "2.12"
SPARK_KAFKA_PACKAGE = f"org.apache.spark:spark-sql-kafka-0-10_{SCALA_VERSION}:{SPARK_VERSION}"
# Not installed on the cluster; version chosen for Spark 3.5, not yet tested there.
ICEBERG_PACKAGE = f"org.apache.iceberg:iceberg-spark-runtime-3.5_{SCALA_VERSION}:1.6.1"

# Kafka 3.1.0 brokers run on the workers (ZooKeeper on the master at localhost:2181).
KAFKA_BROKERS = [
    "nyu-dataproc-w-0.c.hpc-dataproc-19b8.internal:9092",
    "nyu-dataproc-w-1.c.hpc-dataproc-19b8.internal:9092",
]
KAFKA_BOOTSTRAP = ",".join(KAFKA_BROKERS)
