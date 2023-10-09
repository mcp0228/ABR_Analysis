# Brainstorm-Custom-Processes
Repository for all custom-made Brainstorm Processes.

## Overview
[Brainstorm](https://neuroimage.usc.edu/brainstorm/), is an MEG/EEG analysis software within the Matlab environment and allows users to generate and use their own custom-made analysis processes as a plug-in.
This repository is a collection of all the custom processes that were written as part of the author's PhD project at the University of Canterbury, Christchurch, New Zealand.
Although Brainstorm does not require users to own a Matlab license all the processes were written with Matlab. 
The repository comes in two parts; **Auditory Evoked Potentials** and **process_sleepspindle_parameters**.

**Auditory Evoked Potentials** 
<br>This folder contains custom processes for analysing auditory evoked potentials (AEP). 
<br>The processes were mainly used to analyse auditory brainstem responses (ABR; an early component of the AEP) but they can be used for later potentials as well (e.g. cortical auditory evoked potentials; CAEP). 
<br><br>Inside this folder there will be two subfolders; *combined processes* and *individual processes*. 
1. The *individual processes* folder contains all processes that calculate one measurement type from a group of epochs (e.g. one residual noise measurement from 6000 ABR epochs).
2. The *combined processes* folder contains processes that are combined versions of various individual processes from the *individual processes* folder. That is, the processes from *combined processes* output more than one measurement type from a group of epochs (e.g. residual noise, weighted average and noise per epoch). Users can combine processes from the *individual processes* folder to generate their own combined processes. 

**process_sleepspindle_parameters**
<br>This folder contains a process that calculates the parameters of sleep spindles and explanations of what the process does and how it works.
<br>To learn more about this process visit the README.md of this folder. 

### Contact
Contact MinChul Park, MAud(Hons), University of Canterbury, the author of these processes for questions. 
<br>[ORCID](https://orcid.org/0000-0001-5500-1623) & [LinkedIn](linkedin.com/in/minchul-park-a538ab102).
<br>[minchul.park@pg.canterbury.ac.nz](minchul.park@pg.canterbury.ac.nz).

### Acknowledgments
Thanks to support from Brainstorm software engineers, [François Tadel](https://neuroimage.usc.edu/brainstorm/AboutUs/FrancoisTadel?highlight=%28francois%29%7C%28tadel%29#Fran.2BAOc-ois_Tadel.2C_MSc) and [Raymundo Cassani](https://neuroimage.usc.edu/brainstorm/AboutUs/RaymundoCassani?highlight=%28raymundo%29#Raymundo_Cassani.2C_PhD).
<br>Thanks to the author's PhD supervisors [Mike Maslin](https://www.canterbury.ac.nz/science/contact-us/people/michael-maslin.html) and [Greg O'Beirne](https://www.canterbury.ac.nz/science/contact-us/people/greg-obeirne.html).

### Resources
1. [Brainstorm software](https://neuroimage.usc.edu/brainstorm/).
2. [Matlab](https://au.mathworks.com/products/matlab.html).
3. [How to write your own process](https://neuroimage.usc.edu/brainstorm/Tutorials/TutUserProcess).
