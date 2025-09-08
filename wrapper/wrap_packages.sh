#!/bin/sh

WRAP_URL="https://apex192.united-codes.com/ords/ape/ape/wrap"
INPUT_LIST="wrap_list.txt"

# Check if wrap_list.txt exists
if [ ! -f "$INPUT_LIST" ]; then
  echo "File $INPUT_LIST not found!"
  exit 1
fi

# Process each line
while IFS= read -r LINE || [ -n "$LINE" ]; do
  # Trim whitespace
  BASE_NAME=$(echo "$LINE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  # Skip empty lines
  if [ -z "$BASE_NAME" ]; then
    continue
  fi

  INPUT_FILE="${BASE_NAME}"
  OUTPUT_FILE="${BASE_NAME}.wrp"

  # Check if .pkb file exists
  if [ ! -f "$INPUT_FILE" ]; then
    echo "Input file '$INPUT_FILE' not found, skipping..."
    continue
  fi

  echo "Wrapping '$INPUT_FILE'..."

  # Send file content to the REST endpoint
  RESPONSE=$(curl -s -X POST "$WRAP_URL" \
    -H "Content-Type: text/plain" \
    --data-binary @"$INPUT_FILE")

  # If the response is empty, skip saving
  if [ -z "$RESPONSE" ]; then
    echo "No response received for '$INPUT_FILE', skipping..."
    continue
  fi

  # Ensure output directory exists
  OUTPUT_DIR=$(dirname "$OUTPUT_FILE")
  mkdir -p "$OUTPUT_DIR"

  echo "$RESPONSE" > "$OUTPUT_FILE"
  echo "Saved wrapped content to '$OUTPUT_FILE'"

done < "$INPUT_LIST"
