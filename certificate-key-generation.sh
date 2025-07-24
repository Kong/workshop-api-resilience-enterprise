#!/bin/bash

# Basic certificate value(s)
COMMON_NAME="kong_clustering"
SUBJECT="/CN=$COMMON_NAME"

# Check if running Windows Git Bash via MSYSTEM
if [[ -n "$MSYSTEM" ]]; then
  # Git Bash on Windows requires a special -subj format with leading // - add backslashes if required
  SUBJECT="//CN=$COMMON_NAME"
fi

# Inject subject with correct formatting
openssl req -new -x509 -nodes -days 3650 \
    -subj "$SUBJECT" \
    -keyout ./certs/tls.key \
    -out ./certs/tls.crt

if [[ -d "./certs" ]]; then
  echo -e "\nCertificate and key files created successfully."
else
  echo -e "\nError: Failed to create certificate and key files."
  exit 173
fi