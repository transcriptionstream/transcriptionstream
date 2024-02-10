#!/bin/bash

# Display initial message
echo "This script will build the required Docker images for Transcription Stream."
echo "It will first build the 'ts-web' image, followed by the 'ts-gpu' image."
echo "Note: Building the 'ts-gpu' image may take some time as it downloads models for offline use."
echo "After building the images, it will create necessary Docker volumes, start the services, and "
echo "downloade the mistral model for the ts-gpt Ollama endpoint."
echo -n "Do you want to continue? (y/n): "

# Read user input
read answer

# Check if the user input is 'y' or 'Y'
if [ "$answer" != "${answer#[Yy]}" ] ;then
    # Initialize an empty string for build arguments
	build_args=""
	
	# Adjust the path to the .env file
	env_file=".env"
	
	# Check if the .env file exists
	if [ ! -f "$env_file" ]; then
	    echo "Error: .env file does not exist at $env_file"
	    exit 1
	fi
	
	# Read each line from .env, ignoring comments and empty lines
	while IFS= read -r line; do
	    if [[ ! $line =~ ^#.*$ ]] && [[ -n $line ]]; then
	        build_args="$build_args --build-arg $line"
	    fi
	done < "$env_file"

    # Navigate to the ts-web directory and build the Dockerfile
    echo "Building Docker image for ts-web..."
    cd ts-web
    docker build $build_args -t ts-web:latest .
    cd ..

    # Navigate to the ts-gpu directory and build the Dockerfile
    echo "Building Docker image for ts-gpu..."
    cd ts-gpu
    docker build $build_args -t ts-gpu:latest .
    cd ..

    # Create necessary Docker volumes
    echo "Creating Docker volumes..."
    docker volume create --name=transcriptionstream

    # Start the docker-compose services
    echo "Starting services with docker-compose..."
    docker-compose up --detach

#Uncomment to enable ts-gpu local ollama container running mistral
   # Get the model installed on ts-gpt (requires curl)
   # only if ollama is enabled in docker-compose.yaml
    echo "Downloading  mistral model"   
    curl -X POST http://172.30.1.3:11434/api/pull -d '{"name": "mistral"}'

    # Re-attach to compose logs
    echo "Re-attaching to console logs"
    docker-compose logs -f

    echo "All services are up and running."
else
    echo "Installation canceled by the user."
fi
