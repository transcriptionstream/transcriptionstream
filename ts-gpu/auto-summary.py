import os
import subprocess
import pwd
import grp

def scan_and_summarize(base_directory):
    # Get the user and group ID for 'transcriptionstream'
    uid = pwd.getpwnam('transcriptionstream').pw_uid
    gid = grp.getgrnam('transcriptionstream').gr_gid

    # Get the OLLAMA_ENDPOINT_IP from environment variables, and fallback default
    ollama_endpoint_ip = os.environ.get('OLLAMA_ENDPOINT_IP', '172.30.1.3')

    # Iterate through all items in the base directory
    for item in os.listdir(base_directory):
        path = os.path.join(base_directory, item)

        # Check if the item is a directory
        if os.path.isdir(path):
            # Check for the presence of any .txt and .srt files in the subdirectory
            txt_files = [file for file in os.listdir(path) if file.endswith('.txt')]
            srt_exists = any(file.endswith('.srt') for file in os.listdir(path))

            # If .txt and .srt files exist, check for summary.txt
            if txt_files and srt_exists:
                summary_file = os.path.join(path, 'summary.txt')

                # Check if summary.txt does not exist in the subdirectory
                if not os.path.isfile(summary_file):
                    for txt_file in txt_files:
                        # Print message indicating creation of summary.txt for each .txt file
                        print(f"Creating summary.txt for {txt_file} in {path}")
                        # Call the external script with the directory path and the URL
                        command = f'python3 /root/scripts/ts-summarize.py {path} http://{ollama_endpoint_ip}:11434'
                        subprocess.run(command, shell=True)

                        # Change the ownership of the new summary.txt file
                        os.chown(summary_file, uid, gid)

# Example usage
scan_and_summarize('/transcriptionstream/transcribed')
