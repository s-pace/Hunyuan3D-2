#!/bin/bash

# Check if AUTH_TOKEN is set
if [ -z "$AUTH_TOKEN" ]; then
    echo "Error: AUTH_TOKEN environment variable is not set"
    exit 1
fi

# Use API_HOST and API_PORT from environment, default to current values
API_HOST="${API_HOST:-34.90.81.238}"
API_PORT="${API_PORT:-8000}"

# Create a directory for processed files if it doesn't exist
mkdir -p processed

# Create or clear the uid_mapping.txt file
> uid_mapping.txt

# Loop through all PNG files in the current directory
for image in *.png; do
    if [ -f "$image" ]; then
        # Get just the filename without path
        filename=$(basename "$image")
        
        # Convert image to base64
        img_b64_str=$(base64 -i "$image")
        
        # Make API request with authentication and capture response
        echo "Processing $filename..."
        temp_response="/tmp/response_$$.json"
        http_code=$(curl -X POST "http://${API_HOST}:${API_PORT}/generate" \
             -H "Content-Type: application/json" \
             -H "Authorization: Bearer $AUTH_TOKEN" \
             -d '{
                   "image": "'"$img_b64_str"'"
                 }' \
             -w "%{http_code}" \
             -o "$temp_response")
        
        if [ "$http_code" = "200" ]; then
            # Extract UID from response
            uid=$(cat "$temp_response" | grep -o '"uid":"[^"]*"' | cut -d'"' -f4)
            
            # Move the GLB file to processed directory
            mv "$temp_response" "processed/${filename%.png}.glb"
            
            # Save the filename and UID mapping
            echo "$filename: $uid -> processed/${filename%.png}.glb" >> uid_mapping.txt
            echo "Successfully processed $filename (UID: $uid)"
            
            # Move the processed file to prevent reprocessing
            mv "$image" "processed/$filename"
        else
            echo "Error processing $filename (HTTP code: $http_code)"
            cat "$temp_response"
            rm "$temp_response"
        fi
        
        # Wait a bit between requests to not overwhelm the server
        sleep 2
    fi
done

echo "Processing complete. Results saved in uid_mapping.txt" 