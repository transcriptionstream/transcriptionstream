# transcription stream ts-web image 11/2023
#
# Use an official Python runtime as a parent image
FROM python:3.8-slim-buster

# Set the working directory in the docker image
WORKDIR /ts-web

# Copy the content of the local src directory to the working directory
COPY . .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Make port available to the world outside this container
EXPOSE 5000

# Define environment variable
# ENV NAME World

CMD ["bash", "-c", "exec python /ts-web/app.py"]

