#!/bin/bash
# transcription stream transcription and diarization example script - 12/2023
## moved to diarize_parallel.py and added ollama gpt endpoint api and summary option

## 1/2024
## removed date from folder names
## migrated the llm summary being called from this script to ts-control.sh. This lets
##  the next transcription kickoff without waiting for the summary to finish. Summaries
##  will be automatically created for transcriptions missing them.

# Define the root directory and subdirectories
root_dir="/transcriptionstream/incoming/"
transcribed_dir="/transcriptionstream/transcribed/"
sub_dirs=("diarize" "transcribe")

# Define supported audio file extensions
audio_extensions=("wav" "mp3" "flac" "ogg")

# Loop over each subdirectory
for sub_dir in "${sub_dirs[@]}"; do
    incoming_dir="$root_dir$sub_dir/"

    # Loop over each audio file extension
    for ext in "${audio_extensions[@]}"; do
        # Loop over the files in the incoming directory with the current extension
        for audio_file in "$incoming_dir"*."$ext"; do
            # If this file does not exist, skip to the next iteration
            if [ ! -f "$audio_file" ]; then
                continue
            fi

            # Get the base name of the file (without the extension)
            base_name=$(basename "$audio_file" ."$ext")

            # Get the current date/time
            date_time=$(date '+%Y%m%d%H%M%S')

            # Create a new subdirectory in the transcribed directory
            new_dir="$transcribed_dir$base_name"_"$date_time"
            mkdir -p "$new_dir"

            # Check which subdirectory we are in and run the appropriate command
            if [ "$sub_dir" == "diarize" ]; then
                echo "--- diarizing $audio_file..." >> /proc/1/fd/1
                diarize_start_time=$(date +%s)
                python3 diarize_parallel.py --batch-size 16 --whisper-model $DIARIZATION_MODEL --language en -a "$audio_file"
                diarize_end_time=$(date +%s)
                run_time=$((diarize_end_time - diarize_start_time))
            elif [ "$sub_dir" == "transcribe" ]; then
                echo "--- transcribing $audio_file..." >> /proc/1/fd/1
                        whisper_start_time=$(date +%s)
                whisperx --batch_size 12 --model $TRANSCRIPTION_MODEL --language en --output_dir "$new_dir" > "$new_dir/$base_name.txt" "$audio_file"
                        whisper_end_time=$(date +%s)
                        run_time=$((whisper_end_time - whisper_start_time))
            fi

            # Move all files with the same base_name to the new subdirectory
            mv "$incoming_dir$base_name"* "$new_dir/"

            # Migrate this process to ts-control.sh as auto-summary.py
            # Create the summary.txt file from the newly created srt file by sending it to ts-gpt or another ollama api endpoint
            # ts-gpt can be enabled in the docker-compose.yml - if using ts-gpt, your url should be http://172.30.1.3:11434
        #    python3 /root/scripts/ts-summarize.py "$new_dir" http://172.30.1.3:11434

            # Change the owner of the files to the user transcriptionstream
            chown -R transcriptionstream:transcriptionstream "$new_dir"

            # Drop messages to the console
            echo "--- done processing $audio_file - output placed in $new_dir" >> /proc/1/fd/1
            if [ -f "$new_dir/$base_name.txt" ]; then
                echo "transcription: $(cat "$new_dir/$base_name.txt") " >> /proc/1/fd/1;
                echo "Runtime for processing $audio_file = $run_time" >> /proc/1/fd/1;
                echo "------------------------------------";
            fi
        done
    done
done
