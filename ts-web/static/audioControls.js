function playPauseHandler() {
    const audioPlayer = document.getElementById('audioPlayer');
    const playPauseBtn = document.getElementById('playPauseBtn');
    if (audioPlayer.paused) {
        audioPlayer.play();
        playPauseBtn.textContent = '❚❚';
    } else {
        audioPlayer.pause();
        playPauseBtn.textContent = '▶';
    }
}

function skipBackwardHandler() {
    const audioPlayer = document.getElementById('audioPlayer');
    audioPlayer.currentTime = Math.max(audioPlayer.currentTime - 15, 0);
}

function skipForwardHandler() {
    const audioPlayer = document.getElementById('audioPlayer');
    audioPlayer.currentTime = Math.min(audioPlayer.currentTime + 15, audioPlayer.duration);
}

function volumeSliderHandler() {
    const audioPlayer = document.getElementById('audioPlayer');
    const volumeSlider = document.getElementById('volumeSlider');
    audioPlayer.volume = volumeSlider.value;
}

function playbackSpeedHandler() {
    const audioPlayer = document.getElementById('audioPlayer');
    const playbackSpeed = document.getElementById('playbackSpeed');
    audioPlayer.playbackRate = parseFloat(playbackSpeed.value);
}

function timeSliderHandler() {
    const audioPlayer = document.getElementById('audioPlayer');
    const timeSlider = document.getElementById('timeSlider');
    audioPlayer.currentTime = timeSlider.value;
}

function loadedMetadataHandler() {
    const audioPlayer = document.getElementById('audioPlayer');
    const totalTime = document.getElementById('totalTime');
    const timeSlider = document.getElementById('timeSlider');
    const mins = Math.floor(audioPlayer.duration / 60);
    const secs = Math.floor(audioPlayer.duration % 60);
    totalTime.textContent = `${mins}:${secs < 10 ? '0' : ''}${secs}`;
    timeSlider.max = audioPlayer.duration;
}

function timeUpdateHandler() {
    const audioPlayer = document.getElementById('audioPlayer');
    const currentTime = document.getElementById('currentTime');
    const timeSlider = document.getElementById('timeSlider');
    const transcriptionDiv = document.getElementById('transcription');
    const paragraphs = transcriptionDiv.getElementsByTagName('p');
    const mins = Math.floor(audioPlayer.currentTime / 60);
    const secs = Math.floor(audioPlayer.currentTime % 60);
    currentTime.textContent = `${mins}:${secs < 10 ? '0' : ''}${secs}`;
    timeSlider.value = audioPlayer.currentTime;

    for (const paragraph of paragraphs) {
        const time = paragraph.getAttribute('data-time').split(' --> ');
        const start = hmsToSeconds(time[0]);
        const end = hmsToSeconds(time[1]);
        if (audioPlayer.currentTime >= start && audioPlayer.currentTime <= end) {
            paragraph.style.backgroundColor = 'yellow';
            paragraph.scrollIntoView({ behavior: 'smooth', block: 'center', inline: 'start' });
        } else {
            paragraph.style.backgroundColor = 'transparent';
        }
    }
}

function resetAudioControls() {
    console.log('resetAudioControls called');
    const audioPlayer = document.getElementById('audioPlayer');
    const playPauseBtn = document.getElementById('playPauseBtn');
    const timeSlider = document.getElementById('timeSlider');
    const currentTime = document.getElementById('currentTime');
    audioPlayer.pause();
    playPauseBtn.textContent = '▶';
    timeSlider.value = 0;
    currentTime.textContent = '0:00';
}

function addEventListeners() {
    const audioPlayer = document.getElementById('audioPlayer');
    const playPauseBtn = document.getElementById('playPauseBtn');
    const skipBackward = document.getElementById('skipBackward');
    const skipForward = document.getElementById('skipForward');
    const volumeSlider = document.getElementById('volumeSlider');
    const playbackSpeed = document.getElementById('playbackSpeed');
    const timeSlider = document.getElementById('timeSlider');
    const folderSelect = document.getElementById('folderSelect');

    playPauseBtn.removeEventListener('click', playPauseHandler);
    playPauseBtn.addEventListener('click', playPauseHandler);

    skipBackward.removeEventListener('click', skipBackwardHandler);
    skipBackward.addEventListener('click', skipBackwardHandler);

    skipForward.removeEventListener('click', skipForwardHandler);
    skipForward.addEventListener('click', skipForwardHandler);

    volumeSlider.removeEventListener('input', volumeSliderHandler);
    volumeSlider.addEventListener('input', volumeSliderHandler);

    playbackSpeed.removeEventListener('change', playbackSpeedHandler);
    playbackSpeed.addEventListener('change', playbackSpeedHandler);

    timeSlider.removeEventListener('input', timeSliderHandler);
    timeSlider.addEventListener('input', timeSliderHandler);

    audioPlayer.removeEventListener('loadedmetadata', loadedMetadataHandler);
    audioPlayer.addEventListener('loadedmetadata', loadedMetadataHandler);

    audioPlayer.removeEventListener('timeupdate', timeUpdateHandler);
    audioPlayer.addEventListener('timeupdate', timeUpdateHandler);
    
    folderSelect.removeEventListener('change', resetAudioControls);
    folderSelect.addEventListener('change', function() {
        console.log('folderSelect changed');
        resetAudioControls();
    });
}

// Initialize event listeners when the document is ready
document.addEventListener('DOMContentLoaded', function() {
    addEventListeners();
});

