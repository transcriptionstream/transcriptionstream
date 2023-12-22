
# Transcription Stream
Created by [https://transcription.stream](https://transcription.stream) with special thanks to [MahmoudAshraf97](https://github.com/MahmoudAshraf97) and his work on [whisper-diarization](https://github.com/MahmoudAshraf97/whisper-diarization/), and to [jmorganca](https://github.com/jmorganca/ollama) for Ollama and its amazing simplicity in use.

## Overview
Create a turnkey self-hosted offline transcription diarization service with Transcription Stream. A web app and SSH drop zones make this simple to use and implement into your workflows. Ollama allows for a powerful toolset, limited only by your prompt skills, to perform complex operations on your transcriptions.

Use the web interface to upload, listen to, review, and download output files, or drop files via SSH into `transcribe` or `diarize`. Files are processed with output placed into a named and dated folder. Have a quick look at the <a href="https://www.youtube.com/watch?v=3RufeOjnlcE">install</a> and <a href="https://www.youtube.com/watch?v=pbZ8o7_MjG4">ts-web walkthrough</a> videos for a better idea.

Now with Ollama and mistral built in for GPT operations on transcriptions! Summarizing out of the box, but simply change the prompt to fit your needs. If you're like me and don't have enough vram available (12GB 3060) to run ts-gpu and ts-gpt (Ollama) on the same host, simply update the Ollama api url in transcribe_example_d.sh to another Ollama api enpoint and it will utilize that. The feature is currently built to fail open, so if no api endpoint is available the step will just be skipped.
<div align="center">
<h3>mistral summary</h3>
<img src="https://transcription.stream/summary.png" alt="local ollama mistral summary" style="width: 50%;">
</div>

```
prompt_text = f"""
Summarize the transcription below. Be sure to include pertinent information about the speakers, including name and anything else shared.
Provide the summary output in the following style

Speakers: names or identifiers of speaking parties
Topics: topics included in the transcription
Ideas: any ideas that may have been mentioned
Dates: dates mentioned and what they correspond to
Locations: any locations mentioned
Action Items: any action items

Summary: overall summary of the transcription

The transcription is as follows

{transcription_text}

"""
```

Have more questions? Have a chat with our <a href="https://chat.openai.com/g/g-pktPPxVs5-transcription-stream-gptTr">Tanscription Stream GPT</a> 
<div align="center">
<h3>ssh upload and transcribed</h3>
<img src="https://transcription.stream/ts-sshupload.png" width="33%" style="vertical-align: top;" alt="upload file to be diarized to the diarize folder">  <img src="https://transcription.stream/ts-sshtranscribed.png" width="33%" style="vertical-align: top;" alt="transcribed files in their folders">

<h3>ts-web interface</h3>
<a href="https://www.youtube.com/watch?v=pbZ8o7_MjG4">
<img src="https://transcription.stream/ts-web.png" width="66%" alt="Example Image">
</a>
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
- **ts-gpu Image:** (23.7GB - includes necessary models and files to run offline)
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
- **Ollam:** 11434

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

### Ollama api
- **URL:** [http://dockerip:11434](http://dockerip:11434)
- change the prompt used, in `/ts-gpu/ts-summarize.py`

> **Warning:** This is example code for example purposes and should not be used in production environments.

### Customization and Troubleshooting
- Change the password for `transcriptionstream` in the `ts-gpu` Dockerfile.
- Uncomment ts-gpt section in `docker-compose.yml` to enable built-in Ollama mistral. Update `install.sh` and `run.sh` for mistral model install and updates.
- Update the Ollama api endpoint url in /ts-gpu/transcribe_example_d.sh if not running ts-gpt
- Update the secret in `/ts-web/app.py`
- The transcription option uses `whisperx`, but was designed for `whisper`. Note that the raw text output for transcriptions might not display correctly in the console.
- Both the `large-v3` and `large-v2` models are included in the initial build.
- Update the Ollama api url in ts-gpu/transcribe_example_d.sh prior to install/build
- Change the prompt text in ts-gpu/ts-summarize.py to fit your needs. Update ts-web/templates/transcription.html if you want to call it something other than summary.
- 12GB of vram is not enough to run both whisper-diarization and ollama mistral. Whisper-diarization is fairly light on gpu memory out of the box, but Ollama's runner holds over 10GB of gpu memory open after generating for quite sometime, causing the next diarization/transcription to run our of CUDA memory. Since I can't run both on the same host, I've set the batch size for both whisper-diarization and whisperx to 16, from their default 8.
- I need to fix an issue with ts-web that throws an error to console when loading a transcription when a summary.txt file does not also exist.