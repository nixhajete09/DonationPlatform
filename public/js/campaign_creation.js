document.addEventListener('DOMContentLoaded', () => {
    const inputTitel = document.getElementById('input-titel');
    const inputBeloeb = document.getElementById('input-beloeb');
    const inputBeskrivelse = document.getElementById('input-beskrivelse');

    const previewTitel = document.getElementById('preview-titel');
    const previewMaale = document.getElementById('preview-maale');
    const previewBeskrivelse = document.getElementById('preview-beskrivelse');

    if (inputTitel && previewTitel) {
        inputTitel.addEventListener('input', (e) => {
            previewTitel.textContent = e.target.value || 'Din kampagne titel';
        });
    }

    if (inputBeloeb && previewMaale) {
        inputBeloeb.addEventListener('input', (e) => {
            previewMaale.textContent = e.target.value || '0';
        });
    }

    if (inputBeskrivelse && previewBeskrivelse) {
        inputBeskrivelse.addEventListener('input', (e) => {
            previewBeskrivelse.textContent = e.target.value || 'Beskrivelse af hvad jeg samler ind til...';
        });
    }

    const dropZone = document.getElementById('drop-zone');
    const fileInput = document.getElementById('file-input');
    const previewContainer = document.getElementById('preview-media-container');

    if (!dropZone || !fileInput || !previewContainer) {
        return;
    }

    dropZone.addEventListener('click', () => fileInput.click());

    dropZone.addEventListener('dragover', (e) => {
        e.preventDefault();
        dropZone.classList.add('dragover');
    });

    dropZone.addEventListener('dragleave', () => {
        dropZone.classList.remove('dragover');
    });

    dropZone.addEventListener('drop', (e) => {
        e.preventDefault();
        dropZone.classList.remove('dragover');

        const files = e.dataTransfer.files;
        if (files.length > 0) {
            handleFile(files[0], dropZone, previewContainer);
        }
    });

    fileInput.addEventListener('change', (e) => {
        if (e.target.files.length > 0) {
            handleFile(e.target.files[0], dropZone, previewContainer);
        }
    });
});

function handleFile(file, dropZone, previewContainer) {
    if (!file.type.startsWith('image/')) {
        return;
    }

    const reader = new FileReader();
    reader.onload = (e) => {
        let previewImg = document.getElementById('preview-img');

        if (!previewImg) {
            previewImg = document.createElement('img');
            previewImg.id = 'preview-img';
            previewContainer.innerHTML = '';
            previewContainer.appendChild(previewImg);
        }

        previewImg.src = e.target.result;
        previewImg.style.display = 'block';

        const zoneText = dropZone.querySelector('p');
        if (zoneText) {
            zoneText.innerHTML = `Valgt: <strong>${file.name}</strong>`;
        }
    };
    reader.readAsDataURL(file);
}
