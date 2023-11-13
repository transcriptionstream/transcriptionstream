
# Transcription Stream
[https://transcription.stream](https://transcription.stream)

## Overview
This project creates an SSH and web-accessible platform for transcribing and diarizing audio files. Files dropped via SSH into `transcribe` or `diarize` are processed, with outputs placed in a dated folder named after the audio file within the `transcribed` directory. Uploading files via `ts-web` places files into the same folders, allowing for simple processing and retrieval.

**Prerequisite: NVIDIA GPU.**

## Build and Run Instructions

### Creating Volumes
- **Transcription Stream Volume:**
  ```bash
  docker volume create --name=transcriptionstream
  ```

### Building Images from their respective folders
- **ts-web Image:** (Minimal build, very small and fast)
  ```bash
  docker build -t ts-web:latest .
  ```
- **ts-gpu Image:** (Approximately 13.8GB, includes necessary offline models)
  ```bash
  docker build -t ts-gpu:latest .
  ```

### Running the Service
- Start the service using `docker-compose`. This provides updates from running jobs and  noisy `ts-web` logs:
  ```bash
  docker-compose -p transcriptionstream up
  ```

## Additional Information

### Ports
- **SSH:** 22222
- **HTTP:** 5006

### SSH Server Access
- **Port:** 22222
- **User:** `transcriptionstream`
- **Password:** `nomoresaastax`
- **Usage:** Place audio files in `transcribe` or `diarize`. Completed files are stored in `transcribed`.

### Web Interface
- **URL:** [http://dockerip:5006](http://dockerip:5006)
- **Features:**
  - Audio file upload/download
  - Task completion alerts with interactive links
  - HTML5 web player with speed control and transcription highlighting
  - Time-synced transcription scrubbing/highlighting/scrolling

> **Warning:** This is example code for example purposes and should not be used in production environments.

### Customization and Troubleshooting
- Change the password for `transcriptionstream` in the `ts-gpu` Dockerfile.
- Update the secret in `ts-web` app.py.
- The transcription option uses `whisperx`, but was designed for `whisper`. Note that the raw text output for transcriptions might not display correctly in the console.
- The `large-v2` model is not included in the initial build. You can add a `RUN` line in the `ts-gpu` Dockerfile for inclusion during build or adjust `transcribe_example_d.sh` to use the medium model
