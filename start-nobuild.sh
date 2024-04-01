#!/bin/bash

# Display initial message
echo "This script will start pull the needed docker images and start Transcription Stream."
echo "Please note the main image, ts-gpu, is nearly 26GB and may take a hot second to download."
echo "-- it also checks for latest mistral model then connects you to the logs"
echo -n "Do you want to continue? (y/n): "

# Read user input
read answer

# Check if the user input is 'y' or 'Y'
if [ "$answer" != "${answer#[Yy]}" ] ;then

    # Start the docker-compose services
    echo "Starting services with docker-compose..."
    docker-compose -f docker-compose-nobuild.yml up --detach

# If running ts-gpt ollama container, enable this
#    # Get the model installed on ts-gpt (requires curl)
    echo "Downloading  mistral model"
    curl -X POST http://localhost:11434/api/pull -d '{"name": "mistral"}'

    # Re-attach to compose logs
    echo "Re-attaching to console logs"
    docker-compose logs -f
else
    echo "Installation canceled by the user."
fi
