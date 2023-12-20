function parseSRT(srtText) {
    const srtLines = srtText.split('\n\n');
    let html = '';
    srtLines.forEach(line => {
        const parts = line.split('\n');
        if (parts.length > 1) {
            const time = parts[1];
            const text = parts.slice(2).join('<br>');
            html += `<p data-time="${time}">${text}</p>`;
        }
    });
    document.getElementById('transcription').innerHTML = html;
}

function hmsToSeconds(str) {
    const p = str.split(':');
    let s = 0, m = 1;
    while (p.length > 0) {
        s += m * parseInt(p.pop(), 10);
        m *= 60;
    }
    return s;
}

document.addEventListener('DOMContentLoaded', function() {
    var coll = document.getElementById("summaryToggle");
    var content = document.getElementById("summaryContent");

    // Start with content displayed
    content.style.display = "block"; 

    coll.addEventListener("click", function() {
        this.classList.toggle("active");
        if (content.style.display === "block") {
            content.style.display = "none";
        } else {
            content.style.display = "block";
        }
    });
});
