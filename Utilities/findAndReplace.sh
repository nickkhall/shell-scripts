#!/usr/bin/env bash

input_file=''
output_file=''
keyword=''
replacement_word=''
use_uuid=false

# Function to print help message
print_help() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -h, --help            Show this help message"
  echo "  -i, --input_file FILE Specify the input file"
  echo "  -o, --output_file FILE Specify the output file"
  echo "  -kw, --key-word WORD  Specify the keyword to search for"
  echo "  -w, --word WORD       Specify the replacement word"
  echo "  -u, --uuid            Replace the keyword with a UUID"
}

# Parse script arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      print_help
      exit 0
      ;;
    -i|--input_file)
      input_file="$2"
      shift 2
      ;;
    -o|--output_file)
      output_file="$2"
      shift 2
      ;;
    -kw|--key-word)
      keyword="$2"
      shift 2
      ;;
    -w|--word)
      replacement_word="$2"
      shift 2
      ;;
    -u|--uuid)
      use_uuid=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      print_help
      exit 1
      ;;
  esac
done

##################################################
#                   Main Logic                   #
##################################################

if [[ -z "$input_file" || -z "$output_file" || -z "$keyword" ]]; then
  echo "ERROR: Input file, output file, and keyword must be specified"
  print_help
  exit 1
fi

# Ensure input file exists
if [[ ! -f "$input_file" ]]; then
  echo "ERROR: Input file does not exist"
  exit 1
fi

# Read the input file, replace keyword (with UUID or specified word), and write to output file
while IFS= read -r line; do
  if $use_uuid; then
    # Generate a new UUID
    uuid=$(uuidgen)
    # Replace the keyword with the UUID
    line=${line//$keyword/$uuid}
  elif [[ -n "$replacement_word" ]]; then
    # Replace the keyword with the specified replacement word
    line=${line//$keyword/$replacement_word}
  else
    # Replace the keyword with nothing (remove it)
    line=${line//$keyword/}
  fi

  # Append the modified line to the output file
  echo "$line" >> "$output_file"
done < "$input_file"

echo "Processing complete. Check the output file: $output_file"

