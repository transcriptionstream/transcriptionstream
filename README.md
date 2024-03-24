
# Transcription Stream Community Edition
Created by [https://transcription.stream](https://transcription.stream) with special thanks to [MahmoudAshraf97](https://github.com/MahmoudAshraf97) and his work on [whisper-diarization](https://github.com/MahmoudAshraf97/whisper-diarization/), and to [jmorganca](https://github.com/jmorganca/ollama) for [Ollama](https://ollama.com/) and its amazing simplicity in use.

## Overview
Transcription Stream is a turnkey self-hosted diarization service that works completely offline. Out of the box it includes:
- drag and drop diarization and transcription via SSH
- a web interface for upload, review, and download of files
- summarization with Ollama and Mistral
- Meilisearch for full text search 

A web interface and SSH drop zones make this simple to use and implement into your workflows. Ollama allows for a powerful toolset, limited only by your prompt skills, to perform complex operations on your transcriptions. Meiliesearch adds ridiculously fast full text search.

Use the web interface to upload, listen to, review, and download output files, or drop files via SSH into `transcribe` or `diarize`. Files are processed with output placed into a named and dated folder. Have a quick look at the <a href="https://www.youtube.com/watch?v=3RufeOjnlcE">install</a> and <a href="https://www.youtube.com/watch?v=pbZ8o7_MjG4">ts-web walkthrough</a> videos for a better idea.

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

**Prerequisite: NVIDIA GPU**
> **Warning:** The resulting ts-gpu image is ~26GB and might take a hot second to create

## Build and Run Instructions
### Automated Setup and Run
```bash
chmod +x install.sh;
./install.sh;
```
### Run
```bash
chmod +x run.sh;
./run.sh
```

## Additional Information

### Ports
- **SSH:** 22222
- **HTTP:** 5006
- **Ollama:** 11434
- **Meilisearch:** 7700

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

### Meilisearch api
- **URL:** [http://dockerip:7700](http://dockerip:7700)


> **Warning:** This is example code for example purposes and should not be used in production environments without additional security measures.

### Customization and Troubleshooting
- Update variables in the .env file
- Change the password for `transcriptionstream` in the `ts-gpu` Dockerfile.
- Update the Ollama api endpoint IP in .dev if you want to use a different endpoint
- Update the secret in .dev for ts-web
- Use .env to choose which models are included in the initial build.
- Change the prompt text in ts-gpu/ts-summarize.py to fit your needs. Update ts-web/templates/transcription.html if you want to call it something other than summary.
- 12GB of vram may not be enough to run both whisper-diarization and ollama mistral. Whisper-diarization is fairly light on gpu memory out of the box, but Ollama's runner holds enough gpu memory open causing the diarization/transcription to run our of CUDA memory on occasion. Since I can't run both on the same host reliably, I've set the batch size for both whisper-diarization and whisperx to 16, from their default 8, and let a m series mac run the Ollama endpoint.
- Have more questions? Have a chat with our <a href="https://chat.openai.com/g/g-pktPPxVs5-transcription-stream-gptTr">Tanscription Stream GPT</a> 
### To-do
- Need to fix an issue with ts-web that throws an error to console when loading a transcription when a summary.txt file does not also exist. Lots of other annoyances with ts-web, but it's functional.
- Need to add a search/control interface to ts-web for Meilisearch
