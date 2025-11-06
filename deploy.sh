#!/bin/bash
# Deploy Plausible to Google Cloud Run

set -e

PROJECT_ID="propellernet-analytics"
REGION="us-central1"
SERVICE_NAME="plausible"
IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}"

echo "Building Docker image..."
docker build -t ${IMAGE_NAME}:latest -f Dockerfile.production .

echo "Pushing to Google Container Registry..."
docker push ${IMAGE_NAME}:latest

echo "Deploying to Cloud Run..."
gcloud run deploy ${SERVICE_NAME} \
  --image ${IMAGE_NAME}:latest \
  --platform managed \
  --region ${REGION} \
  --project ${PROJECT_ID} \
  --allow-unauthenticated \
  --memory 2Gi \
  --cpu 2 \
  --timeout 300 \
  --max-instances 3

echo "Deployment complete!"
echo "Service URL: https://analytics.propellernet.co.uk"
