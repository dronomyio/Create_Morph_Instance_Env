# Trading Environment Docker Setup

scp build_env.sh to the morph VM instance 
scp build_env.zip  <morph_instance>@ssh.cloud.morph.so:~/
on VM
unzip build_env.zip
docker-compose up --build
docker-compose down
docker-compose up -d

Then enter the Docker container 
```
# First, find your container ID
docker ps

# Then enter the container
docker exec -it CONTAINER_ID bash

# Now you can use Python and Conda inside the container
python --version
conda --version

```


This repository contains a dockerized environment for algorithmic trading development with Conda, Kafka, and Vertica integration. It's designed to be used with Morph.so cloud for creating standardized snapshots that can be easily deployed.

More products can be added.

## Components

- **Conda**: Python package and environment management
- **Kafka**: Distributed event streaming platform
- **Vertica Client**: High-performance analytics database client
- **Jupyter Lab**: Interactive development environment

## Directory Structure

```
morph_docker_env/
├── Dockerfile          # Docker image definition
├── docker-compose.yml  # Docker Compose configuration
├── start.sh            # Container startup script
├── data/               # Mount point for your data files
└── notebooks/          # Mount point for your Jupyter notebooks
```

## Prerequisites

- Docker and Docker Compose installed
- Morph.so account and API key (for deployment to Morph.so)

## Local Usage

1. Create the required directories:
   ```bash
   mkdir -p data notebooks
   ```

2. Build and start the environment:
   ```bash
   docker-compose up -d
   ```

3. Access Jupyter Lab:
   Open your browser and navigate to `http://localhost:8888`

4. Stop the environment:
   ```bash
   docker-compose down
   ```

## Deploying to Morph.so

1. Create a new VM in Morph.so:
   ```python
   from morphcloud.api import MorphCloudClient
   
   client = MorphCloudClient()
   snapshot = client.snapshots.create(
       image_id="morphvm-minimal",
       vcpus=4,
       memory=8192,
       disk_size=50000
   )
   instance = client.instances.start(snapshot.id)
   ```

2. Upload the Docker environment:
   ```python
   with instance.ssh() as ssh:
       # Install Docker and Docker Compose
       ssh.run("apt-get update && apt-get install -y docker.io docker-compose")
       
       # Upload Docker files
       ssh.upload_directory("./morph_docker_env", "/home/ubuntu/morph_docker_env")
       
       # Build and start the environment
       ssh.run("cd /home/ubuntu/morph_docker_env && docker-compose up -d")
   ```

3. Create a snapshot of the configured environment:
   ```python
   standard_environment = instance.snapshot()
   print(f"Created standard environment snapshot: {standard_environment.id}")
   ```

## Customization

### Adding Python Packages

Edit the Dockerfile to add more packages to the conda environment:

```dockerfile
RUN conda install -n trading_env -c conda-forge \
    numpy \
    pandas \
    # Add your packages here \
    -y
```

### Configuring Kafka

Modify the Kafka configuration in the `docker-compose.yml` file:

```yaml
environment:
  KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092
  # Add more Kafka configurations here
```

### Connecting to Vertica

Use the following Python code to connect to your Vertica database:

```python
import vertica_python

conn_info = {
    'host': 'your_vertica_host',
    'port': 5433,
    'user': 'your_username',
    'password': 'your_password',
    'database': 'your_database'
}

with vertica_python.connect(**conn_info) as connection:
    cursor = connection.cursor()
    cursor.execute('SELECT * FROM your_table LIMIT 10')
    for row in cursor.fetchall():
        print(row)
```

## How to Access Python and Conda inside the docker env
## Enter the Docker container
When you run docker-compose build, it creates a Docker container with Python and Conda installed inside that container, but these tools aren't automatically installed on the host VM itself.
Think of Docker as a separate, isolated environment:
The Dockerfile we created installs Python and Conda inside the container
The host VM (where you're running commands as root) doesn't automatically get these tools
```
# First, find your container ID
docker ps

# Then enter the container
docker exec -it CONTAINER_ID bash

# Now you can use Python and Conda inside the container
python --version
conda --version

```


## Troubleshooting

- **Kafka Connection Issues**: Ensure the Kafka service is running with `docker-compose logs kafka`
- **Jupyter Access Problems**: Check if Jupyter is running with `docker-compose logs trading-environment`
- **Vertica Connection Failures**: Verify your Vertica credentials and network connectivity
