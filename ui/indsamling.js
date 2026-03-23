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