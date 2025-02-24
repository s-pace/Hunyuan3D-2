#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <uid>"
    exit 1
fi

MODEL_ID=$1

OUTPUT_FILE="output_${MODEL_ID}.glb"

# Check if SECRET environment variable is set
if [ -z "$SECRET" ]; then
    echo "Error: SECRET environment variable is not set"
    exit 1
fi

# Use API_HOST from environment, default to localhost
API_HOST="${API_HOST:-127.0.0.1}"
API_PORT="${API_PORT:-8000}"

# Get the status and model data with authentication
RESPONSE=$(curl -s -H "Authorization: Bearer $SECRET" "http://${API_HOST}:${API_PORT}/status/${MODEL_ID}")

# Check if the response contains "completed"
if echo "$RESPONSE" | grep -q "completed"; then
    # Extract the base64 string and decode it to the output file
    echo "$RESPONSE" | grep -o '"model_base64":"[^"]*"' | cut -d'"' -f4 | base64 -d > "$OUTPUT_FILE"
    echo "Model downloaded successfully to $OUTPUT_FILE"
else
    echo "Model is not ready or processing failed"
    echo "Response: $RESPONSE"
fi