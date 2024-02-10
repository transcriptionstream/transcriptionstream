from flask import Flask, render_template, request, jsonify, session, send_file
from werkzeug.utils import secure_filename
import os
import shutil
from datetime import datetime

app = Flask(__name__)
# Use the TS_WEB_SECRET_KEY environment variable as the secret key, and the fallback
app.secret_key = os.environ.get('TS_WEB_SECRET_KEY', 'some_secret_key')

TRANSCRIBED_FOLDER = '/transcriptionstream/transcribed'
UPLOAD_FOLDER = '/transcriptionstream/incoming'
ALLOWED_EXTENSIONS = set(['mp3', 'wav', 'ogg', 'flac'])

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

session_start_time = datetime.now()


def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route('/')
def index():
    # Reset the session variable on page load
    session['alerted_folders'] = []
    session['session_start_time'] = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    folder_paths = [os.path.join(TRANSCRIBED_FOLDER, f) for f in os.listdir(TRANSCRIBED_FOLDER) if os.path.isdir(os.path.join(TRANSCRIBED_FOLDER, f))]
    
    # Filter folders to only include those containing an .srt file
    valid_folders = []
    for folder in folder_paths:
        files = os.listdir(folder)
        if any(file.endswith('.srt') for file in files):
            valid_folders.append(os.path.basename(folder))
    
    sorted_folders = sorted(valid_folders, key=lambda s: s.lower())  # Sorting by name in ascending order, case-insensitive
    
    return render_template('index.html', folders=sorted_folders)

@app.route('/load_files', methods=['POST'])
def load_files():
    folder = request.form.get('folder')
    if not folder:
        return jsonify(error='Folder not specified'), 400
    
    folder_path = os.path.join(TRANSCRIBED_FOLDER, folder)
    if not os.path.exists(folder_path):
        return jsonify(error='Folder does not exist'), 404
    
    files = [f for f in os.listdir(folder_path) if not f.startswith('.')]
    audio_file = next((f for f in files if f.lower().endswith(('.mp3', '.wav', '.ogg', '.flac'))), None)
    srt_file = next((f for f in files if f.lower().endswith('.srt')), None)
    
    return jsonify(audio_file=audio_file, srt_file=srt_file, files=files)


@app.route('/get_file/<path:folder>/<path:filename>', methods=['GET'])
def get_file(folder, filename):
    folder_path = os.path.join(TRANSCRIBED_FOLDER, folder)
    file_path = os.path.join(folder_path, filename)
    return send_file(file_path, as_attachment=True, download_name=filename)


@app.route('/upload', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
        if 'file' not in request.files:
            return redirect(request.url)
        file = request.files['file']
        if file.filename == '':
            return redirect(request.url)
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            return render_template('upload.html', message="File uploaded successfully! Redirecting - you will be notified once the transcription is complete", redirect=True)
    return render_template('upload.html')
    
@app.route('/upload_transcribe', methods=['POST'])
def upload_transcribe():
    if 'file' not in request.files:
        return redirect(request.url)
    file = request.files['file']
    if file.filename == '':
        return redirect(request.url)
    if file:
        filename = secure_filename(file.filename)
        file.save(os.path.join(app.config['UPLOAD_FOLDER'], 'transcribe', filename))
        return render_template('upload.html', message="File uploaded successfully to Transcribe!")

@app.route('/upload_diarize', methods=['POST'])
def upload_diarize():
    if 'file' not in request.files:
        return redirect(request.url)
    file = request.files['file']
    if file.filename == '':
        return redirect(request.url)
    if file:
        filename = secure_filename(file.filename)
        file.save(os.path.join(app.config['UPLOAD_FOLDER'], 'diarize', filename))
        return render_template('upload.html', message="File uploaded successfully to Diarize!")


@app.route('/check_alert', methods=['GET'])
def check_alert():
    all_folders = [os.path.join(TRANSCRIBED_FOLDER, f) for f in os.listdir(TRANSCRIBED_FOLDER) if
                   os.path.isdir(os.path.join(TRANSCRIBED_FOLDER, f))]

    alert_data = []
    for folder_path in all_folders:
        folder_name = os.path.basename(folder_path)
        folder_ctime = datetime.fromtimestamp(os.path.getctime(folder_path))

        if folder_ctime > session_start_time:
            # Define the list of possible audio file extensions
            audio_extensions = ['.mp3', '.wav', '.ogg', '.flac']

            # Check if the folder contains at least one audio file with any of the allowed extensions and one .srt file
            has_audio = any(file.endswith(tuple(audio_extensions)) for file in os.listdir(folder_path))
            has_srt = any(file.endswith('.srt') for file in os.listdir(folder_path))

            if has_audio and has_srt:
                alert_data.append({
                    'folder_name': folder_name,
                    'folder_time': folder_ctime.strftime('%Y-%m-%d %H:%M:%S')
                })

    return jsonify(alert=alert_data)


@app.route('/delete_folder/<path:folder>', methods=['DELETE'])
def delete_folder(folder):
    folder_path = os.path.join(TRANSCRIBED_FOLDER, folder)
    if not os.path.exists(folder_path):
        return jsonify(success=False, error='Folder does not exist'), 404
    
    try:
        shutil.rmtree(folder_path)
        return jsonify(success=True)
    except Exception as e:
        print(f"Error deleting folder: {e}")
        return jsonify(success=False, error='Failed to delete folder'), 500    
    
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
