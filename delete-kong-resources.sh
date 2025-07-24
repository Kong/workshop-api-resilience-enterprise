#!/bin/bash

echo "Stopping and removing Kong Data Plane deployment..."

# Bring down the Docker Compose stack
docker compose down

# Optional: Remove the certs directory if no longer needed
if [ -d "./certs" ]; then
    echo "Removing certificates..."
    rm -rf ./certs
fi

# Optional: Remove the .env file if it was created
if [ -f "./.env" ]; then
    echo "Removing environment file..."
    rm -f ./.env
fi

echo "Kong Data Plane deployment removed successfully!"
