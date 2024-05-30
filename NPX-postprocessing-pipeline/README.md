# NPX-pipeline
Automated post-processing pipeline for NPX data. 

Requirements:
* Matlab (>=2018b)
* Neuropixels data should be acquired with SpikeGLX (by Bill Karsh https://billkarsh.github.io/SpikeGLX/) 
* The pipeline relies on CatGT and TPrime tools (by Bill Karsh https://billkarsh.github.io/SpikeGLX/)

Main function is *RunPostProc_and_move_to_Winstor*. Follow pop-up windows to select current session and subject folder on server, everything else is automated.

What the pipeline does: 

* Extacts times of events from all behavioral lines that were acquired with NIdaq, parses them by trial
* Creates folder structure for raw and processed data on Winstor 
* Runs CatGT on NPX *.ap.bin files for each probe
* Copies raw data and CatGT output to remote backup (Winstor) 
