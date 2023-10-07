# Process Sleep Spindle Parameters
Brainstorm custom-made process to calculate sleep spindle duration, frequency, max peak-to-peak amplitude, and degree of symmetry.

## How the process works
The following highlights several points the user needs to be aware of before using this process. 
1) This process assumes that the EEG data was already filtered between 11 - 16 Hz.
2) This process is *not* an automatic spindle detection algorithm.
3) This process only works with already identified and extracted discrete individual spindles (i.e. cannot work on raw EEG files).
4) This process will generate 4 files each according to a spindle parameter - duration, frequency, amplitude and symmetry.
5) Each file x-axis = spindle number but the units will = Time (s). Unfortunately, this cannot be changed.

### Calculations and definitions

### Additional resources
To learn more about this process and how it was written visit these two Brainstorm forums written by the author. 
1) [Extracting manually identified events for further analysis](https://neuroimage.usc.edu/forums/t/extracting-manually-identified-events-for-further-analysis/41841)
2) [Custom process for individual epochs with different time samples](https://neuroimage.usc.edu/forums/t/custom-process-for-individual-epochs-with-different-time-samples/42260)

### Disclaimer 
As mentioned above, this requires [Brainstorm software](https://neuroimage.usc.edu/brainstorm/) to be used. 
Brainstorm, an MEG/EEG analysis software within the Matlab environment allows users to generate and use their own custom-made analysis processes as a plug-in.
To learn more about writing your own processes to be used within Brainstorm visit this tutorial; [How to write your own process](https://neuroimage.usc.edu/brainstorm/Tutorials/TutUserProcess).
