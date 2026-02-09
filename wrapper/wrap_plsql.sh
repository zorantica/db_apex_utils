#!/bin/sh

WRAP_URL="https://xepa.right-thing.solutions/ords/apex242/wrap/wrap/wrap"
INPUT_LIST="wrap_list.txt"

# Check if wrap_list.txt exists
if [ ! -f "$INPUT_LIST" ]; then
  echo "File $INPUT_LIST not found!"
  exit 1
fi

# Process each line
while IFS= read -r LINE || [ -n "$LINE" ]; do
  # Trim whitespace
  INPUT_FILE=$(echo "$LINE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  # Skip empty lines
  [ -z "$INPUT_FILE" ] && continue


  # Check input file exists
  if [ ! -f "$INPUT_FILE" ]; then
    echo "Input file '$INPUT_FILE' not found, skipping..."
    continue
  fi

  # Output file: remove extension, add .pkw
  BASE_NO_EXT="${INPUT_FILE%.*}"
  OUTPUT_FILE="${INPUT_FILE%?}w"

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
