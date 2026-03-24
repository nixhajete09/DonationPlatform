// Enkel JavaScript til live opdatering
document.addEventListener('DOMContentLoaded', () => {
    // Find alle inputs
    const inputTitel = document.getElementById('input-titel');
    const inputBeloeb = document.getElementById('input-beloeb');
    const inputBeskrivelse = document.getElementById('input-beskrivelse');

    // Find alle preview-elementer
    const previewTitel = document.getElementById('preview-titel');
    const previewMaale = document.getElementById('preview-maale');
    const previewBeskrivelse = document.getElementById('preview-beskrivelse');

    // Live opdatering af Titel
    inputTitel.addEventListener('input', (e) => {
        previewTitel.textContent = e.target.value || "Din kampagne titel";
    });

    // Live opdatering af Beløb
    inputBeloeb.addEventListener('input', (e) => {
        previewMaale.textContent = e.target.value || "0";
    });

    // Live opdatering af Beskrivelse
    inputBeskrivelse.addEventListener('input', (e) => {
        previewBeskrivelse.textContent = e.target.value || "Beskrivelse af hvad jeg samler ind til...";
    });
});
const dropZone = document.getElementById('drop-zone');
const fileInput = document.getElementById('file-input');
const previewCard = document.querySelector('.map-box'); // Vi erstatter kortet med billedet i preview

// 1. Gør det muligt at klikke på zonen for at åbne fil-vælger
dropZone.addEventListener('click', () => fileInput.click());

// 2. Håndter "drag" visuelt
dropZone.addEventListener('dragover', (e) => {
    e.preventDefault();
    dropZone.classList.add('dragover');
});

dropZone.addEventListener('dragleave', () => {
    dropZone.classList.remove('dragover');
});

// 3. Håndter selve "drop"
dropZone.addEventListener('drop', (e) => {
    e.preventDefault();
    dropZone.classList.remove('dragover');
    
    const files = e.dataTransfer.files;
    if (files.length > 0) {
        handleFile(files[0]);
    }
});

// 4. Håndter hvis de vælger via klik
fileInput.addEventListener('change', (e) => {
    if (e.target.files.length > 0) {
        handleFile(e.target.files[0]);
    }
});

// Funktion der læser filen og viser den i preview
function handleFile(file) {
    if (!file.type.startsWith('image/')) {
        alert("Vælg venligst et billede.");
        return;
    }

    const reader = new FileReader();
    reader.onload = (e) => {
        // Find eller opret et img-tag i preview-sektionen
        let previewImg = document.getElementById('preview-img');
        
        if (!previewImg) {
            previewImg = document.createElement('img');
            previewImg.id = 'preview-img';
            // Skjul kortet/placeholder når billedet kommer ind
            previewCard.innerHTML = ''; 
            previewCard.appendChild(previewImg);
        }
        
        previewImg.src = e.target.result;
        previewImg.style.display = 'block';
        
        // Opdater teksten i upload-zonen
        dropZone.querySelector('p').innerHTML = `Valgt: <strong>${file.name}</strong>`;
    };
    reader.readAsDataURL(file);
}