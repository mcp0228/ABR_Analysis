# Sleep Spindle Parameters
Brainstorm custom-made process to calculate sleep spindle duration, frequency, max peak-to-peak amplitude, and degree of symmetry.

## How the process works
The following highlights several points the user needs to be aware of before using this process. 
1) This process assumes that the EEG data was already filtered between 11 - 16 Hz (i.e. the σ band).
2) This process is *not* an automatic spindle detection algorithm.
3) This process only works with already identified and extracted discrete individual spindles (i.e. cannot work on raw EEG files).
4) This process will generate 4 files each according to a spindle parameter - duration, frequency, amplitude and symmetry.
5) Each file x-axis = spindle number but the units will = Time (s). Unfortunately, this cannot be changed.
6) Calculation of spindle density is *not* part of this process. 

### Calculations and definitions
<p align="center">
  <img width="250" height="300" src="https://github.com/mcp0228/Brainstorm-Custom-Processes/assets/134780775/00408a54-a025-43e9-b459-eb63a070842e">
</p>

This process generates four output files which correspond to four sleep spindle parameters. These were calculated/defined as follows.

**1) Duration.**
<br>Since this process is for spindles that were already identified and extracted from EEG recording, the "duration" of a single discrete spindle equals the duration of the time window of the extracted spindle.

**2) Frequency.**
<br>With the duration of a spindle already known, the frequency (or in the case of the above diagram, intra-spindle frequency) of a single discrete spindle = reciprocal (cycle number/duration).
<br>The MATLAB [*findpeaks*](https://au.mathworks.com/help/signal/ref/findpeaks.html) (find local maxima) function was used to find all the peaks of a spindle and the [*length*](https://au.mathworks.com/help/matlab/ref/length.html) function was used to count the number of peaks.

**3) Maximum peak-to-peak amplitude.**
<br>The MATLAB *findpeaks* function was used from 2) to find the amplitude of each peak.
<br>The *findpeaks* function was used on the negative version of the data (i.e. data*-1) to find the amplitudes of the negative peaks.
<br>The [*max*](https://au.mathworks.com/help/matlab/ref/max.html) function was used to calculate the maximum positive and negative peaks of a single spindle. 
<br>Therefore, max peak-to-peak amplitude = max positive peak - max negative peak.

**4) Symmetry.**
<br>With the location (in seconds) of all peaks and the maximum peak for each spindle already known by the *findpeaks* function, the symmetry was calculated as follows; symmetry = % of (time location of maximum peak/duration). 
<br>Meaning, that a spindle symmetry value of 70% indicates that the maximum peak for that spindle is at 70% of its duration. 

### Additional resources
To learn more about this process and how it was written visit these two Brainstorm forums written by the author. 
1) [Extracting manually identified events for further analysis](https://neuroimage.usc.edu/forums/t/extracting-manually-identified-events-for-further-analysis/41841)
2) [Custom process for individual epochs with different time samples](https://neuroimage.usc.edu/forums/t/custom-process-for-individual-epochs-with-different-time-samples/42260)

Two articles were used in particular for writing this process.<br>Sleep spindle parameter definitions used in this process were obtained from the second article. 
1) [Sleep Spindles: Mechanisms and Functions](https://pubmed.ncbi.nlm.nih.gov/31804897/)
2) [Sleep-spindle detection: crowdsourcing and evaluating performance of experts, non-experts and automated methods](https://pubmed.ncbi.nlm.nih.gov/24562424/)

### Disclaimer 
As mentioned above, this requires [Brainstorm software](https://neuroimage.usc.edu/brainstorm/) to be used. 
<br>Brainstorm, an MEG/EEG analysis software within the Matlab environment allows users to generate and use their own custom-made analysis processes as a plug-in.
To learn more about writing your own processes to be used within Brainstorm visit this tutorial; [How to write your own process](https://neuroimage.usc.edu/brainstorm/Tutorials/TutUserProcess).
