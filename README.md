# vid2audio.sh

`vid2audio.sh` is a versatile Bash script designed to convert video files into audio files (MP3 by default) or to extract the original audio stream without re-encoding. The script can process individual files or entire directories, and it supports a wide range of commonly used video formats. With the recursive option, you can also search through subdirectories to find and process video files.

## Features

- Convert video files to MP3 or extract audio without re-encoding.
- Supports multiple video formats: MP4, MOV, MKV, AVI, WMV, FLV, MPEG, MPG, and WEBM.
- Process a single file or batch process all supported video files in a directory.
- Optional recursive search through subdirectories.
- Automatically detects the correct audio file extension when extracting without re-encoding.

## Usage

### Process a file, re-encode the stream and save it to .mp3
```bash
./vid2audio.sh -f </path/to/save/input_file> [-o </path/to/save/output_file.mp3>]
```

### Process all files in a directory (recursively, don't re-encode stream)
```bash
./vid2audio.sh -d </path/to/directory> [-o </path/to/save/directory>] [-c] [-r]
```

### Options

- `-f, --file <input_file>`: Specify the input video file. Required if not using `-d`.
- `-o, --output <output_file>`: Specify the output file for a single file conversion or output directory for batch processing. Defaults to `${PWD}/vid2audio-output.mp3`.
- `-d, --directory <directory>`: Process all supported video files in the specified directory.
- `-r, --recursive`: Recursively search for video files in the directory and its subdirectories.
- `-c, --copy`: Extract the audio stream without re-encoding and save it with the appropriate file extension.
- `-h, --help`: Display the help message.

### Examples

**Convert a single video file to MP3:**
```bash
./vid2audio.sh -f video.mp4 -o audio.mp3
```

**Extract the original audio stream without re-encoding:**
```bash
./vid2audio.sh -f video.mkv -c
```

**Convert all supported video files in a directory to MP3:**
```bash
./vid2audio.sh -d /path/to/videos -o /path/to/output_directory
```

**Recursively process all supported video files in a directory and its subdirectories:**
```bash
./vid2audio.sh -d /path/to/videos -r -c
```

## Supported Video Formats

- **MP4** (`.mp4`)
- **MOV** (`.mov`)
- **MKV** (`.mkv`)
- **AVI** (`.avi`)
- **WMV** (`.wmv`)
- **FLV** (`.flv`)
- **MPEG** (`.mpeg`, `.mpg`)
- **WEBM** (`.webm`)

## Requirements

- `ffmpeg`: The script relies on `ffmpeg` to handle video and audio processing. Make sure `ffmpeg` is installed and accessible in your system's PATH.

## Installation

1. Clone the repository or download the script.
2. Make the script executable:
   ```bash
   chmod +x vid2audio.sh
   ```
3. Run the script as described in the usage section.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.