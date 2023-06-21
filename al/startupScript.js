var htmlToEmbed = ' \
    <div id="status"></div> \
    <label for="brightness">Brightness</label> \
	<input type="range" min="-1" max="1" value="0" step="0.1" id="brightness"> \
	<label for="contrast">Contrast</label> \
	<input type="range" min="-1" max="1" value="0" step="0.1" id="contrast"> \
	<label for="hue">Hue</label> \
	<input type="range" min="-360" max="360" value="0" step="10" id="hue"> \
	<label for="sat">Saturation</label> \
	<input type="range" min="-1" max="1" value="0" step="0.1" id="sat"> \
'

var d1 = document.getElementById('controlAddIn');
d1.insertAdjacentHTML('beforeend', htmlToEmbed);

document.getElementById('status').innerText = "Initializing wasm...";
const go = new Go();
let memoryBytes;
let mod, inst, bytes;
let imageType = "png";
WebAssembly.instantiateStreaming(fetch(Microsoft.Dynamics.NAV.GetImageResource('./shimmer.wasm')), go.importObject).then((result) => {
    document.getElementById('status').innerText = "Initialization complete.";
    mod = result.module;
	inst = result.instance;
	memoryBytes = new Uint8Array(inst.exports.mem.buffer)
    go.run(inst);
});