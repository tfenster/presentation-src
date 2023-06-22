
controladdin ImageAdjustControl
{
    RequestedHeight = 100;
    MinimumHeight = 100;
    MaximumHeight = 100;
    RequestedWidth = 800;
    MinimumWidth = 800;
    MaximumWidth = 800;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;
    StartupScript = 'startupScript.js';
    Scripts = 'wasm_exec.js', 'additional.js';
    Images = 'shimmer.wasm';
    procedure connectImage();
    event ControlReady();
}