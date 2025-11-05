#!/bin/bash

# Script to create user account directly via Cloud Run exec

echo "Creating user account via Cloud Run service..."

# Execute command in the running Cloud Run instance
gcloud run services proxy plausible --port=8080 --region=us-central1 &
PROXY_PID=$!

sleep 5

# Create user via direct database connection using the app's environment
curl -X POST http://localhost:8080/api/create-user \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Colin Differ",
    "email": "colin@propellernet.co.uk", 
    "password": "Bz$g%*2)G*3!vZ#a"
  }'

# Clean up
kill $PROXY_PID