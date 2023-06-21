
async function connectImage() {
    const element = parent.document.querySelector('[aria-label="Specifies the picture of the customer, for example, a logo."]');
    const arrayBuffer = await (await fetch(element.src)).arrayBuffer();
    bytes = new Uint8Array(arrayBuffer);
    loadImage(bytes);
}

function displayImage(buf) {
    let blob = new Blob([buf], {'type': 'png'});
    parent.document.querySelector('[aria-label="Specifies the picture of the customer, for example, a logo."]').src = URL.createObjectURL(blob);
}