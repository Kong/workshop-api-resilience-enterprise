#!/bin/bash

CERT_PATH="./certs/tls.crt"
KEY_PATH="./certs/tls.key"

# Check if the certificate and key files exist
if [[ ! -f "${CERT_PATH}" ]] || [[ ! -f "${KEY_PATH}" ]]; then
  echo -e "\nError: Certificate or key file not found. Creating..."

  # Create the certs
  mkdir -p certs
  chmod +x certificate-key-generation.sh
  ./certificate-key-generation.sh
fi

# Deploy Kong Data Plane
echo -e "\nDeploying services using Docker Compose..."
docker compose up -d

# Check if deployment was successful
# shellcheck disable=SC2181
if [[ $? -eq 0 ]]; then
  echo "Kong Data Plane deployed successfully and connected to Control Plane."
else
  echo -e "\nError: Failed to deploy Kong Data Plane."
  exit 172
fi