function checkAlert() {
    fetch('/check_alert')
        .then(response => response.json())
        .then(data => {
            let alertList = document.getElementById('alertList');
            let folderSelect = document.getElementById('folderSelect');
            
            let currentFolders = JSON.parse(sessionStorage.getItem('folders') || '[]');
            
            data.alert.forEach(alert => {
                if(!currentFolders.includes(alert.folder_name)) {
                    let alertId = `${alert.folder_name}-${alert.folder_time.replace(/[^a-zA-Z0-9]/g, "")}`;
                    
                    if (!document.getElementById(alertId)) {
                        let option = document.createElement('option');
                        option.value = alert.folder_name;
                        option.text = alert.folder_name;
                        folderSelect.add(option);
                        
                        let alertItem = document.createElement('div');
                        alertItem.id = alertId;
                        alertItem.className = 'alert-item';
                        alertItem.innerText = `New Transcription: ${alert.folder_name} - ${alert.folder_time}`;
                        
                        alertItem.addEventListener('click', function() {
                            folderSelect.value = alert.folder_name;
                            if ("createEvent" in document) {
                                var evt = document.createEvent("HTMLEvents");
                                evt.initEvent("change", false, true);
                                folderSelect.dispatchEvent(evt);
                            } else {
                                folderSelect.fireEvent("onchange");
                            }
                        });
                        
                        alertList.insertBefore(alertItem, alertList.firstChild);
                    }
                    
                    // Adding the folder_name to the currentFolders array and updating the sessionStorage
                    currentFolders.push(alert.folder_name);
                    sessionStorage.setItem('folders', JSON.stringify(currentFolders));
                }
            });
        });
}

setInterval(checkAlert, 5000);
