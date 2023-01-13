# NaLyser
Matlab data analysis software
-----------------------------

Overview of the files
![Overview of the files](https://github.com/CT-Dylan/NaLyser/blob/main/NaLyserFiles.jpg?raw=true "Overview of the files")


-----------------------------
1. How to install the software ?

-----------------------------
2. How to select the data files located in a given folder ?
[![NL How to select files](https://img.youtube.com/vi/IkyiP1m_GEY/maxresdefault.jpg)](https://www.youtube.com/embed/IkyiP1m_GEY) </br>

Note: Data files in subfolders are, in principle, also detected.

Example of use of the keyword mechanism:
- A given folder contains the following files obtained from measurements with the TTF Box: <br />
Folder/ <br />
 &nbsp; &nbsp; > Analysis_Bottle1_pH6_Charac.dat <br />
 &nbsp; &nbsp; > Analysis_Bottle2_pH7_Charac.dat <br />
 &nbsp; &nbsp; > Analysis_Bottle3_pH8_Charac.dat <br />
 &nbsp; &nbsp; > Test/ <br />
 &nbsp; &nbsp; &nbsp; &nbsp;    > AnalysisTest1_Charac.dat <br />
 &nbsp; &nbsp; &nbsp; &nbsp;    > AnalysisTest2_Charac.dat <br />
- If the keyword is "Analysis", all the files would be selected.
- If the keyword is "Analysis_" or "Analysis_Bottle", only the 3 first files would be selected.

Note: 2 others conditions for that to work is that the "TTF Box" option in the Machine Dropdown should have been selected,
and that the "Characteristics" checkbox should have been checked.

-----------------------------
3. How to select plotting parameters ?
[![NL How to select files](https://img.youtube.com/vi/GIp33SmEZpQ/maxresdefault.jpg)](https://www.youtube.com/embed/GIp33SmEZpQ) </br>

New parameters can be added to the list by adding a row in the excel file parameterDictionary.csv located in the software files.
The elements to insert in the different cells are:
> Keyword - Display name (with a second part that can be written in mathematical form with LaTeX syntax) - Unit (if blank, it is mandatory to leave at least a space in that cell) 

On the one hand, there are "internal" parameters (VGS, VDS, Freq, Time,...) that are dependent on the type of files used. On the other hand, external parameters are inserted through the file/sheet names and the parameterDictionary.csv file. 

To insert a parameter in a name, proper use of underscores needs to be followed.<br />
A data file needs to match the following structure: whatever1_whatever2_ParameterA ValueA_ParameterB ValueB_ ... .extension<br />
For instance: analysis_testA_pH6_BGV-1_T34.2_TransFunc_GM.dat or Joshua_Experiment_k310_Charac.dat<br />
A sheet of an excel file just need to follow the structure: ParameterA ValueA_ParameterB ValueB_ ... _ ParameterX ValueX<br />
Also the each of the said parameters needs to have an entry in the parameterDictionary.csv file (as discussed above).<br />

-----------------------------
4.

-----------------------------
5. How to save or load GUI settings ?
[![NL How to select files](https://img.youtube.com/vi/YMMWcuXi_RQ/maxresdefault.jpg)](https://www.youtube.com/embed/YMMWcuXi_RQ) </br>
There are 3 buttons:
- Save: to save the GUI settings into a .mat file at a chosen location;
- Save & Quit: same as above but also closes the window after the operation;
- Load: retrieve settings from a .mat file and update the GUI.

Note: The settings are also automatically saved at the software files location when the program is run successfully.
