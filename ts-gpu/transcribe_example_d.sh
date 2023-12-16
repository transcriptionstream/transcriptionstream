#!/bin/bash
# transcription stream transcription and diarization example script - 12/2023
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
                python3 diarize.py -a "$audio_file"
                        diarize_end_time=$(date +%s)
                        run_time=$((diarize_end_time - diarize_start_time))
            elif [ "$sub_dir" == "transcribe" ]; then
                echo "--- transcribing $audio_file..." >> /proc/1/fd/1
                        whisper_start_time=$(date +%s)
                whisperx --model large-v3 --language en --output_dir "$new_dir" > "$new_dir/$base_name.txt" "$audio_file"
#                whisper "$audio_file" --model medium.en --language en --task transcribe --output_dir "$new_dir" > "$new_dir/$base_name.txt"
                        whisper_end_time=$(date +%s)
                        run_time=$((whisper_end_time - whisper_start_time))
            fi

            # Move all files with the same base_name to the new subdirectory
            mv "$incoming_dir$base_name"* "$new_dir/"

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