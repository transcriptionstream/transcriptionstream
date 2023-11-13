function loadFiles() {
    const folder = document.getElementById('folderSelect').value;
    if (!folder) return;
    const formData = new URLSearchParams();
    formData.append('folder', folder);

    fetch('/load_files', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData.toString()
    })
        .then(response => response.json())
        .then(data => {
            const audioPlayer = document.getElementById('audioPlayer');
            const transcriptionDiv = document.getElementById('transcription');
            const fileSelect = document.getElementById('fileSelect');

            audioPlayer.src = `/get_file/${folder}/${data.audio_file}`;
            audioPlayer.load();

            fileSelect.innerHTML = '<option value="" disabled selected>Select a file</option>';
            data.files.forEach(file => {
                const option = document.createElement('option');
                option.value = file;
                
                // Extract the file extension and set it as the text content
                const parts = file.split('.');
                const extension = parts.length > 1 ? parts[parts.length - 1] : file;
                option.textContent = extension;
                
                fileSelect.appendChild(option);
            });

            const xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    parseSRT(xhr.responseText);
                }
            };
            xhr.open('GET', `/get_file/${folder}/${data.srt_file}`, true);
            xhr.send();
        });
    addEventListeners();
}

function downloadFile() {
    const folder = document.getElementById('folderSelect').value;
    const file = document.getElementById('fileSelect').value;
    if (!folder || !file) return;
    window.location.href = `/get_file/${folder}/${file}`;
}

function deleteFolder() {
    const folderSelect = document.getElementById('folderSelect');
    const selectedFolder = folderSelect.options[folderSelect.selectedIndex].value;
    
    if (!selectedFolder) {
        alert('Please select a folder to delete.');
        return;
    }
    
    if (!confirm(`Are you sure you want to delete the folder: ${selectedFolder}?`)) {
        return;
    }
    
    fetch(`/delete_folder/${selectedFolder}`, {
        method: 'DELETE',
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }
        return response.json();
    })
    .then(data => {
        if (data.success) {
            alert('Folder deleted successfully.');
            location.reload();
        } else {
            alert('Failed to delete folder.');
        }
    })
    .catch((error) => {
        console.error('Fetch error:', error);
        alert('Failed to delete folder.');
    });
}
