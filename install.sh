#!/bin/bash

# Update the system
sudo yum update -y

# Install Java 17
sudo dnf install java-17-amazon-corretto -y

# Install Maven (default version)
sudo dnf install maven -y

# Install Docker
sudo yum install docker -y

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add ec2-user to the docker group
sudo usermod -aG docker ec2-user

# Restart Docker
sudo systemctl restart docker

# Adjust Docker socket permissions
sudo chmod 666 /var/run/docker.sock

# Verify Java, Maven, and Docker installation
java -version
mvn -version
docker --version

# Navigate to the home directory
cd /home/ec2-user

# Ensure Dockerfile exists before proceeding
if [ ! -f "Dockerfile" ]; then
    echo "Dockerfile not found in /home/ec2-user. Exiting..."
    exit 1
fi

# Build Docker image
docker build -t my_app_image .

# Run a container from the built image
docker run -itd --name my_app_container -p 8091:8091 my_app_image

# Verify the running container
docker ps -a
