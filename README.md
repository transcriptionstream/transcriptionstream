
# Transcription Stream
Created by [https://transcription.stream](https://transcription.stream) with special thanks to [MahmoudAshraf97](https://github.com/MahmoudAshraf97) and his work on [whisper-diarization](https://github.com/MahmoudAshraf97/whisper-diarization/)

## Overview
Create a self-hosted offline transcription and diarization service with Transcription Stream. A web app and SSH drop zones make this simple to use and impliment into your workflows.
Use the web interface to upload, listen to, review, and download output files, or drop files via SSH into `transcribe` or `diarize`. Files are processed with output placed into a named and dated folder.<div align="center">
<h3>ssh upload and transcribed</h3>
<img src="https://transcription.stream/ts-sshupload.png" width="33%" style="vertical-align: top;" alt="upload file to be diarized to the diarize folder">  <img src="https://transcription.stream/ts-sshtranscribed.png" width="33%" style="vertical-align: top;" alt="transcribed files in their folders">

<h3>ts-web interface</h3>
<img src="https://transcription.stream/ts-web.png" width="66%" alt="Example Image">

<h3>ts-gpu diarization example </h3>
<a href="https://www.youtube.com/watch?v=UAgbcZjR4mM">
    <img src="https://transcription.stream/videothumb.png" alt="watch video on youtube" style="width: 66%;">
  </a>
</div>


**Prerequisite: NVIDIA GPU**
> **Warning:** The resulting ts-gpu image is 23.7GB and might take a hot second to create

## Build and Run Instructions
### Automated Setup and Run
```bash
chmod +x install.sh;
./install.sh;
```

### Manual Setup
### Creating Volume
- **Transcription Stream Volume:**
  ```bash
  docker volume create --name=transcriptionstream
  ```

### Build Images from their respective folders
- **ts-web Image:** (Minimal build, very small and fast)
  ```bash
  docker build -t ts-web:latest .
  ```
- **ts-gpu Image:** (Approximately 13.8GB, includes necessary offline models)
  ```bash
  docker build -t ts-gpu:latest .
  ```

### Run the Service
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
- The `large-v3` model is included in the initial build.