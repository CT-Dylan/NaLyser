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
- A given folder contains the following files obtained from measurements with the TTF Box:
> Folder/
  >> Analysis_Bottle1_pH6_Charac.dat
  >> Analysis_Bottle2_pH7_Charac.dat
  >> Analysis_Bottle3_pH8_Charac.dat
  >> Test/
      >>> AnalysisTest1_Charac.dat
      >>> AnalysisTest2_Charac.dat
- If the keyword is "Analysis", all the files would be selected.
- If the keyword is "Analysis_" or "Analysis_Bottle", only the 3 first files would be selected.

Note: 2 others conditions for that to work is that the "TTF Box" option in the Machine Dropdown should have been selected,
and that the "Characteristics" checkbox should have been checked.
