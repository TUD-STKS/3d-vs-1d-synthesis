# 3d-vs-1d-synthesis
A study on the impact of different methods to produce the high-frequency component of synthetic speech spectra.

# Dependencies
The following additional toolboxes are required to run the code without any further modifications: 
- Audio Toolbox
- DSP System Toolbox
- Image Processing Toolbox
- Signal Processing Toolbox

# Getting started
This repo contains submodule and you therefore need to clone it using the following command:
```
git clone --recursive https://github.com/TUD-STKS/3d-vs-1d-synthesis
```

# Stimuli generation
Run stimuli/GenerateStimuli.m to (re-)generate the stimuli. The synthesized utterances can be found in stimuli/dev.

## Settings for VocalTractLab transfer function calculation:
Radiation impedance: Piston in wall
Additional options: all OFF
Energy losses: Boundary layer resistance ON, heat conduction losses ON, Soft Walls ON, Hagen-Poiseuille resistance OFF

## Baseline stimuli (MM condition)
The full-bandwidth transfer functions calculated using the multimodal method are used to produce the baseline stimuli.

## 1d condition
For the 1d condition, the MM transfer function is low-pass filtered and combined with the high-pass filtered 1d transfer function.

## BWE condition
For the BWE condition, the synthesized MM sounds are low-pass filtered at 4 kHz and downsampled to 8 kHz. Then, the acoustic signal is upsampled to 32 kHz and its frequency content is extended to 16 kHz. This happens in two steps (8 kHz -> 16 kHz -> 32 kHz).
Finally, the utterance is upsampled to 44.1 kHz to match the sampling rate of the other stimuli.

# Methods
Run the script `transfer-functions/PlotTransferFunctions.m` to compare the 1d and MM transfer functions.
Run `stimuli/BlendingTest.m` to visualize two examples (one male, one female) of the transfer function blending.
Run the script `stimuli/CompareSpectrograms.m` to visualize the spectrograms of all synthesized utterances side-by-side.

See the folder `doc` for some pre-generated figures.





