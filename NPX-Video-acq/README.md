# NPX-Video-acq

Code for video acquisition during recordings with Neuropixel probes (1.0 and newer).
Code is written for acquisition with Point Grey (FLIR) Chameleon 3 cameras, but apart from control of GPIO signal the aquisiion code should be camera-agnostic. 

Requirements:

    Matlab (>=2018b)
    Cameras need to be recognized in Matlab Image Acquisition Toolbox. This could require intallation of model-specific drivers and matlab adaptors.
