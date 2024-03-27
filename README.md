# LE3Storage
This is a code space that I will use to manage some files for my leading edge erosion project.

I need to go through and carefully document what all these files are and what the different scripts do.

On a high level, the process is as follows:

- The first script creates a matrix of design points to run the simulator on
- The second script uses the library of set-up functions to run the simulator and organize the output
- The third script either explores the results, or builds a database from the completed runs
- Optional, the jointables script puts the datatables from the simulation together into one database 

Then, I have tried different types of analysis.  I have the Morris Method Script.  I have the GASP Emulator scripts.  And I have played around with some machine learning on MatLab.

The goal is to generate a dataset of sensor and SCADA outputs from virtual turbines experiencing erosion of various types.  Then, from that dataset, I want to determine which features are descrimatory for classifying erosion and predecting the level of erosion on each section of each blade.  I also want to develop a collection of erosion patterns or profiles which better represent 

