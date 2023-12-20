#!/bin/bash

# Display initial message
echo "This script will start Transcription Stream."
echo "Note: Script checks for latest mistral model (if running ts-gpt in docker-compose.yml)  then connects you to the logs"
echo -n "Do you want to continue? (y/n): "

# Read user input
read answer

# Check if the user input is 'y' or 'Y'
if [ "$answer" != "${answer#[Yy]}" ] ;then

    # Start the docker-compose services
    echo "Starting services with docker-compose..."
    docker-compose up --detach

# If running ts-gpt ollama container, enable this
#    # Get the model installed on ts-gpt (requires curl)
#    echo "Downloading  minstral model"
#    curl -X POST http://localhost:11434/api/pull -d '{"name": "mistral"}'

    # Re-attach to compose logs
    echo "Re-attaching to console logs"
    docker-compose logs -f
else
    echo "Installation canceled by the user."
fi
