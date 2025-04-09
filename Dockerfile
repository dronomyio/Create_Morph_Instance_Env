FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    gnupg2 \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    openjdk-11-jdk \
    python3 \
    python3-pip \
    git \
    unzip \
    netcat \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh

# Add conda to path
ENV PATH=$CONDA_DIR/bin:$PATH

# Create conda environment
RUN conda create -n trading_env python=3.9 -y
SHELL ["/bin/bash", "-c"]
RUN echo "source activate trading_env" >> ~/.bashrc
ENV PATH $CONDA_DIR/envs/trading_env/bin:$PATH

# Install Python packages in the conda environment
RUN conda install -n trading_env -c conda-forge \
    numpy \
    pandas \
    scipy \
    matplotlib \
    scikit-learn \
    jupyterlab \
    ipykernel \
    -y

# Install Kafka
ENV KAFKA_VERSION=3.5.1
ENV SCALA_VERSION=2.13
ENV KAFKA_HOME=/opt/kafka
RUN mkdir -p $KAFKA_HOME && \
    wget -q https://downloads.apache.org/kafka/$KAFKA_VERSION/kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz -O /tmp/kafka.tgz && \
    tar -xzf /tmp/kafka.tgz -C /opt && \
    mv /opt/kafka_$SCALA_VERSION-$KAFKA_VERSION/* $KAFKA_HOME && \
    rm -rf /opt/kafka_$SCALA_VERSION-$KAFKA_VERSION && \
    rm /tmp/kafka.tgz

# Add Kafka to PATH
ENV PATH=$PATH:$KAFKA_HOME/bin

# Install Vertica client
RUN wget -q https://www.vertica.com/client_drivers/12.0.x/12.0.4-0/vertica-client-12.0.4-0.x86_64.tar.gz -O /tmp/vertica-client.tar.gz && \
    mkdir -p /opt/vertica && \
    tar -xzf /tmp/vertica-client.tar.gz -C /opt/vertica && \
    rm /tmp/vertica-client.tar.gz

# Install Vertica Python client
RUN pip install vertica-python

# Create working directory
WORKDIR /app

# Copy startup script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Expose ports
# Kafka
EXPOSE 9092
# Zookeeper
EXPOSE 2181
# Jupyter
EXPOSE 8888

# Set entrypoint
ENTRYPOINT ["/app/start.sh"]
