#!/bin/bash
set -euo pipefail

# Script Description: Converts video files to MP3 or extracts the audio stream without re-encoding.
# Can process a single file or various video formats in a directory recursively if -r is specified.
# Author: [Your Name]
# Version: 1.5.0
# License: MIT
# Creation Date: [dd/mm/yyyy]
# Last Modified: [dd/mm/yyyy]
# Usage: vid2audio.sh -f <input_file> [-o <output_file>] [-c] | -d <directory> [-o <output_directory>] [-c] [-r]

# Default values
OUTPUT_FILE="${PWD}/vid2audio-output.mp3"
COPY_MODE=false
RECURSIVE_MODE=false

# Function to display ASCII art
show_ascii() {
  echo "
██╗   ██╗██╗██████╗ ██████╗  █████╗ ██╗   ██╗██████╗ ██╗ ██████╗
██║   ██║██║██╔══██╗╚════██╗██╔══██╗██║   ██║██╔══██╗██║██╔═══██╗
██║   ██║██║██║  ██║ █████╔╝███████║██║   ██║██║  ██║██║██║   ██║
╚██╗ ██╔╝██║██║  ██║██╔═══╝ ██╔══██║██║   ██║██║  ██║██║██║   ██║
 ╚████╔╝ ██║██████╔╝███████╗██║  ██║╚██████╔╝██████╔╝██║╚██████╔╝
  ╚═══╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝ ╚═════╝
                                                                "
}

# Function to display help information
show_help() {
  echo "
Usage: $0 -f <input_file> [-o <output_file>] [-c] | -d <directory> [-o <output_directory>] [-c] [-r]

Converts a video file or all .mp4, .mov, .mkv, .avi, .wmv, .flv, .mpeg, .mpg, and .webm files in a directory to MP3
or extracts the audio stream without re-encoding if the -c or --copy option is used. If no options are provided, the
script will convert a single video to MP3.

Options:
  -f, --file <input_file>       Input video file (required if not using -d).
  -o, --output <output_file>    Output MP3 or audio file (default: ${PWD}/vid2audio-output.mp3).
  -d, --directory <directory>   Convert all supported video files in the specified directory.
  -r, --recursive               Recursively search for video files in the directory.
  -c, --copy                    Extract audio stream without re-encoding and save with appropriate extension.
  -h, --help                    Display this help message.
"
}

# Function for error handling
error_exit() {
  echo "[+] Error: $1" >&2
  exit 1
}

# Function to determine the correct file extension based on the audio codec
get_extension() {
  local input_file="$1"
  local codec

  codec=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$input_file")

  case "$codec" in
    mp3) echo "mp3" ;;
    aac) echo "m4a" ;;
    flac) echo "flac" ;;
    wav) echo "wav" ;;
    alac) echo "m4a" ;;
    *) error_exit "[+] Unsupported audio codec: $codec" ;;
  esac
}

# Function to convert a single video file to MP3 or extract the audio stream
convert_to_audio() {
  local input_file="$1"
  local output_file="$2"

  # Check if output file already exists
  if [ -f "$output_file" ]; then
    echo "[+] Warning: '$output_file' already exists."
    echo "[+] Do you want to overwrite it? (y/n)"
    read -r overwrite
    if [[ "$overwrite" != "y" ]]; then
      echo "[+] Skipping conversion for '$input_file'."
      return
    fi
  fi

  if [ "$COPY_MODE" = true ]; then
    local extension
    extension=$(get_extension "$input_file")
    output_file="${output_file%.*}.$extension"
    echo "[+] Extracting audio from '$input_file' to '$output_file'..."
    ffmpeg -i "$input_file" -vn -acodec copy "$output_file"
  else
    echo "[+] Converting '$input_file' to '$output_file'..."
    ffmpeg -i "$input_file" -map 0:a "$output_file"
  fi
  echo "[+] Operation completed."
}

# Function to process all video files in a directory
process_directory() {
  local dir="$1"
  local output_dir="${2:-${PWD}}"

  # Find all supported video files in the specified directory (recursively if enabled)
  local files
  if [ "$RECURSIVE_MODE" = true ]; then
    files=$(find "$dir" -type f \( -iname "*.mp4" -o -iname "*.mov" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.wmv" -o -iname "*.flv" -o -iname "*.mpeg" -o -iname "*.mpg" -o -iname "*.webm" \))
  else
    files=$(find "$dir" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.mov" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.wmv" -o -iname "*.flv" -o -iname "*.mpeg" -o -iname "*.mpg" -o -iname "*.webm" \))
  fi

  if [[ -z "$files" ]]; then
    error_exit "[+] No supported video files found in directory '$dir'."
  fi

  echo "[+] The following files were found in the directory '$dir':"
  echo "$files"
  echo "[+] Do you want to process all these files? (y/n)"
  read -r confirmation

  if [[ "$confirmation" != "y" ]]; then
    error_exit "[+] Operation cancelled by user."
  fi

  # Process each file, handling spaces in file names correctly
  IFS=$'\n'
  for file in $files; do
    local output_file="${output_dir}/$(basename "${file%.*}.mp3")"
    convert_to_audio "$file" "$output_file"
  done
  unset IFS
}

# Main function to encapsulate script logic
main() {
  local input_file=""
  local output_file="$OUTPUT_FILE"
  local directory=""
  local output_dir=""

  while [[ $# -gt 0 ]]; do
    case $1 in
      -f|--file)
        input_file="$2"
        shift 2
        ;;
      -o|--output)
        output_file="$2"
        output_dir="$2"
        shift 2
        ;;
      -d|--directory)
        directory="$2"
        shift 2
        ;;
      -r|--recursive)
        RECURSIVE_MODE=true
        shift
        ;;
      -c|--copy)
        COPY_MODE=true
        shift
        ;;
      -h|--help)
        show_ascii
        show_help
        exit 0
        ;;
      *)
        show_ascii
        show_help
        error_exit "Invalid option: $1"
        ;;
    esac
  done

  if [[ -n "$directory" ]]; then
    if [[ -z "$output_dir" ]]; then
      output_dir="$PWD"
    fi
    show_ascii
    process_directory "$directory" "$output_dir"
  elif [[ -n "$input_file" ]]; then
    if [[ -z "$output_file" || "$output_file" == "$PWD/vid2audio-output.mp3" ]]; then
      output_file="${PWD}/$(basename "${input_file%.*}.mp3")"
    fi
    show_ascii
    convert_to_audio "$input_file" "$output_file"
  else
    show_ascii
    show_help
    error_exit "[+] No input file or directory provided"
  fi
}

# Execute the main function
main "$@"