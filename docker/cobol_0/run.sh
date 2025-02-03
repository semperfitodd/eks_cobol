#!/bin/bash

set -e

if [ -z "$INPUT_FILE" ] || [ -z "$OUTPUT_FILE" ]; then
  echo "Error: INPUT_FILE and OUTPUT_FILE environment variables must be set."
  exit 1
fi

cobc -x -free TransformCSV.cbl -o TransformCSV

./TransformCSV
