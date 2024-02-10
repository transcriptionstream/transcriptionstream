import json
import sys
import os
import requests
import subprocess
import re

# Check if both a folder path and API base URL were provided as command line arguments
if len(sys.argv) < 3:
    print("Please provide a folder path and an API base URL as command line arguments.")
    sys.exit(1)

folder_path = sys.argv[1]
api_base_url = sys.argv[2]

# Find the text file with the same name as the folder
folder_name = os.path.basename(folder_path)
## Remove the timestamp (_YYYYMMddhhmmss) from the folder name
folder_name_without_timestamp = re.sub(r'_[0-9]{14}$', '', folder_name)
txt_file_name = folder_name_without_timestamp + '.txt'
txt_file_path = os.path.join(folder_path, txt_file_name)

if not os.path.exists(txt_file_path):
    print(f"No text file found with the name '{txt_file_name}' in the provided folder: {folder_path}")
    sys.exit(1)

# Read the text file
with open(txt_file_path, 'r', encoding='utf-8') as file:
    transcription_text = file.read()

# The text for the prompt
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
# JSON payload
payload = {
    "model": "mistral",
    "prompt": prompt_text,
    "stream": False,
    "keep_alive": "5s"
}

# Try to send a GET request to check if the API is running
try:
    api_response = requests.get(api_base_url, timeout=5)
    if api_response.status_code == 200 and api_response.text == "Ollama is running":
        print("API endpoint is running.")
    else:
        print("Invalid response from API endpoint")
        sys.exit(1)
except requests.ConnectionError as e:
    print("Ollama connection error: API endpoint down. Moving along.")
    sys.exit(1)
except requests.Timeout as e:
    print("Ollama request timed out: API endpoint down. Moving along..")
    sys.exit(1)
except Exception as e:
    print("Error connecting to the API endpoint: {}".format(str(e)))
    sys.exit(1)

# Send the POST request with the base URL and path
request_url = api_base_url + '/api/generate'
response = None
try:
    response = requests.post(request_url, json=payload)
except Exception as e:
    print("Error sending request to API endpoint: {}".format(e))
    sys.exit(1)

# Check if the request was successful and print or exit accordingly
if response is not None and response.status_code == 200:
    # Parse the JSON response
    json_data = response.json()
    # Extract the 'response' portion
    response_text = json_data.get('response', 'No response found')
    # Print the formatted response text
    ## we don't really need this
    ##print(response_text)

    # Write the summary to a file named summary.txt in the same folder
    with open(os.path.join(folder_path, 'summary.txt'), 'w', encoding='utf-8') as summary_file:
        summary_file.write(response_text)

    # After writing the summary, call index-single.py so the info is indexed with MeiliSearch
    index_single_script = '/root/scripts/index-single.py'
    subprocess.run(['python3', index_single_script, folder_path])

else:
    if response is not None:
        print("Request failed with status code:", response.status_code)
        print("Error message from API:", json_data.get('error', ''))
        sys.exit(1)
