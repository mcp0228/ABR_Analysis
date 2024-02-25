# Sleep Spindle Parameters
Brainstorm custom-made process to calculate sleep spindle parameters: duration, frequency, max. peak-to-peak amplitude, degree of symmetry, RMS amplitude and activity. 

## How the process works
The following highlights several points the user needs to be aware of before using this process. 
1) This process assumes that the EEG data was already filtered between 11 - 16 Hz (i.e. the σ band).
2) This process is *not* an automatic spindle detection algorithm.
3) This process only works with already identified and extracted discrete individual spindles (i.e. cannot work on raw EEG files).
4) This process will generate 6 files each according to a spindle parameter - duration, frequency, max. peak-to-peak amplitude, symmetry, RMS amplitude, and activity. 
5) Each file x-axis = spindle number but the units will = Time (s). Unfortunately, this cannot be changed.
6) Calculation of spindle density is *not* part of this process. 

### Calculations and definitions
<p align="center">
  <img width="250" height="300" src="https://github.com/mcp0228/Brainstorm-Custom-Processes/assets/134780775/00408a54-a025-43e9-b459-eb63a070842e">
</p>

This process generates four output files which correspond to four sleep spindle parameters. These were calculated/defined as follows.

**1) Duration.**
<br>Since this process is for spindles that were already identified and extracted from EEG recording, the "duration" of a single discrete spindle equals the duration of the time window of the extracted spindle.
The corresponding Brainstorm file output looks like below. There is only one line as the "duration" is the time window meaning the time value is equal for all channels. 
![EEG_All_CTRL8_L_Sleep_band_SS_Dur_94](https://github.com/park-minchul/Brainstorm-Custom-Processes/assets/134780775/47e35b8a-ee3a-44df-84a7-c4355d132f10)

**2) Frequency.**
<br>With the duration of a spindle already known, the frequency (or in the case of the above diagram, intra-spindle frequency) of a single discrete spindle = reciprocal (cycle number/duration).
The Matlab [*findpeaks*](https://au.mathworks.com/help/signal/ref/findpeaks.html) (find local maxima) function was used to find all the peaks of a spindle and the [*length*](https://au.mathworks.com/help/Matlab/ref/length.html) function was used to count the number of peaks. The corresponding Brainstorm file output looks like below.
![EEG_All_CTRL8_L_Sleep_band_SS_Fre_94](https://github.com/park-minchul/Brainstorm-Custom-Processes/assets/134780775/39aedaae-30e3-4f1d-b63b-e55a1c935409)

**3) Maximum peak-to-peak amplitude.**
<br>The Matlab *findpeaks* function was used from 2) to find the amplitude of each peak.
<br>The *findpeaks* function was used on the negative version of the data (i.e. data*-1) to find the amplitudes of the negative peaks.
<br>The [*max*](https://au.mathworks.com/help/Matlab/ref/max.html) function was used to calculate the maximum positive and negative peaks of a single spindle. 
<br>Therefore, max peak-to-peak amplitude = max positive peak - max negative peak. The corresponding Brainstorm file output looks like below.
![EEG_All_CTRL8_L_Sleep_band_SS_Amp_94](https://github.com/park-minchul/Brainstorm-Custom-Processes/assets/134780775/df75a794-8f35-48b9-bd25-ea97c828a2d0)

**4) Symmetry.**
<br>With the location (in seconds) of all peaks and the maximum peak for each spindle already known by the *findpeaks* function, the symmetry was calculated as follows; symmetry = % of (time location of maximum peak/duration). 
Meaning, that a spindle symmetry value of 70% indicates that the maximum peak for that spindle is at 70% of its duration. The corresponding Brainstorm file output looks like below.
![EEG_All_CTRL8_L_Sleep_band_SS_Sym_94](https://github.com/park-minchul/Brainstorm-Custom-Processes/assets/134780775/0e0a8363-d811-4dde-943f-855052bf105c)

**5) RMS amplitude.**
<br>Calculates the RMS amplitude of every spindle and displays this over the given number of spindles. The corresponding Brainstorm file output looks like below.
![EEG_All_CTRL_CTRL8_sleep_epochs_band_SS_Rms_126](https://github.com/park-minchul/Brainstorm-Custom-Processes/assets/134780775/5da23536-5a23-4ecd-9b65-4026fa8be3de)

**6) Activity.**
<br>Activity is calculated by max. peak-to-peak amplitude (calculated in 3)*duration (calculated in 1). The corresponding Brainstorm file output looks like below.
![EEG_All_CTRL_CTRL8_sleep_epochs_band_SS_Act_126](https://github.com/park-minchul/Brainstorm-Custom-Processes/assets/134780775/7bccf788-1433-4104-8fa2-12a9d85fa8c0)

### Additional resources
**Relevant Brainstorm forums written by the author**
1) [Extracting manually identified events for further analysis](https://neuroimage.usc.edu/forums/t/extracting-manually-identified-events-for-further-analysis/41841)
2) [Custom process for individual epochs with different time samples](https://neuroimage.usc.edu/forums/t/custom-process-for-individual-epochs-with-different-time-samples/42260)

**References**
<br>Two articles were used in particular for writing this process.
<br>Sleep spindle parameter definitions used in this process were obtained from the second article. 
1) [Sleep Spindles: Mechanisms and Functions](https://pubmed.ncbi.nlm.nih.gov/31804897/)
2) [Sleep-spindle detection: crowdsourcing and evaluating performance of experts, non-experts and automated methods](https://pubmed.ncbi.nlm.nih.gov/24562424/)

### Cite As ###
MinChul Park (2023). Sleep spindle parameters, [GitHub](https://github.com/park-minchul/Brainstorm-Custom-Processes/tree/main/Sleep%20Spindle%20Parameters), University of Canterbury, Christchurch, New Zealand.
