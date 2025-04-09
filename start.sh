#!/bin/bash
set -e

# Activate conda environment
source /opt/conda/etc/profile.d/conda.sh
conda activate trading_env

# Start Zookeeper in background
echo "Starting Zookeeper..."
$KAFKA_HOME/bin/zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties &
sleep 10

# Start Kafka in background
echo "Starting Kafka..."
$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties &
sleep 10

# Create a default topic
echo "Creating default topic 'trading-data'..."
$KAFKA_HOME/bin/kafka-topics.sh --create --topic trading-data --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1 || true

# Start Jupyter Lab
echo "Starting Jupyter Lab..."
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password=''
