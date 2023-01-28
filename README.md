# NaLyser
Matlab data analysis software
-----------------------------

Overview of the files
![Overview of the files](https://github.com/CT-Dylan/NaLyser/blob/main/NaLyserFiles.jpg?raw=true "Overview of the files")


-----------------------------
1. How to install the software?

-----------------------------
2. How to select the data files located in a given folder?
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
3. How to select plotting parameters?
[![NL How to select files](https://img.youtube.com/vi/GIp33SmEZpQ/maxresdefault.jpg)](https://www.youtube.com/embed/GIp33SmEZpQ) </br>

New parameters can be added to the list by adding a row in the excel file parameterDictionary.csv located in the software files.
The elements to insert in the different cells are:
> Keyword - Display name (with a second part that can be written in mathematical form with LaTeX syntax) - Unit (if blank, it is mandatory to leave at least a space in that cell) 

More information on LaTeX with MATLAB here:
https://nl.mathworks.com/help/matlab/creating_plots/greek-letters-and-special-characters-in-graph-text.html </br>


On the one hand, there are "internal" parameters (VGS, VDS, Freq, Time,...) that are dependent on the type of files used. On the other hand, external parameters are inserted through the file/sheet names and the parameterDictionary.csv file. 

To insert a parameter in a name, proper use of underscores needs to be followed.<br />
A data file needs to match the following structure: whatever1_whatever2_ParameterA ValueA_ParameterB ValueB_ ... .extension<br />
For instance: analysis_testA_pH6_BGV-1_T34.2_TransFunc_GM.dat or Joshua_Experiment_k310_Charac.dat<br />
A sheet of an excel file just need to follow the structure: ParameterA ValueA_ParameterB ValueB_ ... _ ParameterX ValueX<br />
Also the each of the said parameters needs to have an entry in the parameterDictionary.csv file (as discussed above).<br />

-----------------------------
4. How to customize figure display settings?
[![NL How to select files](https://img.youtube.com/vi/3QvG4RIGcxM/maxresdefault.jpg)](https://www.youtube.com/embed/3QvG4RIGcxM) </br>

Since the content has been defined, it is high time to look into the form. One may be disatisfied by the default figure display settings. Hence, a possibility to change some of them was made available. Namely the font size, line width, family of line colours, grid display, autoscale, window size, subfigures disposition.
In order to test the chosen settings, a preview button can display a sample figure. </br>

In addition, one can also choose whether the figures should be shown and/or saved in .fig and .png format. </br>

The two families of line colours are:
- Distinct, where the line colours are made as distinguishable as possible. First, by using the 7 default colours of Matlab, and then 40 other colours defined by an algorithm.
- Gradient, where the line colours go from blue (RGB: [69 202 255]) to red (RGB: [255 27 107]), and the number of subdivisions is defined by the number spinner (below the Distinct/Gradient dropdown). </br>

No uniform autoscale means that each subfigure will be rescaled individually, based on its own minima and maxima. With the uniform autoscale, the rescaling will be the same for all subfigures, depending on the absolute maxima and minima of all the curves displayed. </br>

Custom window size can be done by inserting exactly 2 (integer) numbers in the Window dropdown, namely the width and the height in pixel. </br>

For the subfigures disposition, one must start by making a grid in the Geometry panel. Then, for each subfigure, one must enter once and only once a given value of "subfigure parameter". If no data has that value as "subfigure parameter", then the subfigure slot will remain blank.
For example, if the "subfigure parameter" is "Channel", and only channels from 1 to 16 were recorded, then entering 0 or -1 in one of the cell will leave the subfigure slot at that position blank. Conversely, entering 4 will display at that position the curves for the Channel 4.

-----------------------------
5. How to save or load GUI settings?
[![NL How to select files](https://img.youtube.com/vi/YMMWcuXi_RQ/maxresdefault.jpg)](https://www.youtube.com/embed/YMMWcuXi_RQ) </br>
There are 3 buttons:
- Save: to save the GUI settings into a .mat file at a chosen location;
- Save & Quit: same as above but also closes the window after the operation;
- Load: retrieve settings from a .mat file and update the GUI.

Note: The settings are also automatically saved at the software files location when the program is run successfully.

-----------------------------
6. What happens when the program is run?
[![NL How to select files](https://img.youtube.com/vi/aOkbowkxJzc/maxresdefault.jpg)](https://www.youtube.com/embed/aOkbowkxJzc) </br>

Once the program is run, the program will parse through the files and look for the different parameters available. From there, two possibie scenarios can be considered:
- There is a mismatch (shown in red) between the parameters detected and the one the user wished to see displayed.
- No issue is found. </br>

In the last case, all the parameters will be displayed in a pop-up window alongside how they were classified, with what names they will be displayed, their units and how their values will be dealt with. </br>

They are classified as plotting parameters (see point 3.) or as "working point". By default, the working points have no effect, i.e. the program will run while totally and utterly disregarding the values of the working points. To change that, one can enter a value instead of the default word "ignore". For instance, if VDS was a working point and the user wants to plot curves for all channels but only for VDS = -3V, then the number -3 should be entered in the Operation column instead of the word "ignore".</br>

By default, the name interpreter is LaTex, so that mathematical symbols and greek letters could be used. Therefore, the name can be made up of a normal text part, followed by a math part in-between dollar signs (and in that order). </br>
More info on LaTeX with MATLAB here: https://nl.mathworks.com/help/matlab/creating_plots/greek-letters-and-special-characters-in-graph-text.html </br>

The units were subdivided in two parts a prefix (milli, centi, deca, mega,...) and the unit itself. It allows the user to use files where internal parameters have different orders of magnitude. For example, if one file uses mA and V, whereas the other uses µA and mV, they can still be analysed and put together on the same graph. </br> 

So far, for plotting parameters, only the "All" operation is available. Changing it will cause issues. </br>

Once the user is satisfied, the pop-up window can be closed. Then, the program will read the files for the data and plot the curves.

-----------------------------
7. How to analyse the data?
[![NL How to select files](https://img.youtube.com/vi/bRsPTepg2Z8/maxresdefault.jpg)](https://www.youtube.com/embed/bRsPTepg2Z8) </br>
[![NL How to select files](https://img.youtube.com/vi/FbOWJRGi-wQ/maxresdefault.jpg)](https://www.youtube.com/embed/FbOWJRGi-wQ) </br>
[![NL How to select files](https://img.youtube.com/vi/zRJdQKHtsjw/maxresdefault.jpg)](https://www.youtube.com/embed/zRJdQKHtsjw) </br>
[![NL How to select files](https://img.youtube.com/vi/OxYiRbWbzEc/maxresdefault.jpg)](https://www.youtube.com/embed/OxYiRbWbzEc) </br>

The curves of each (sub)figures can be further analysed. For that reason some tool were designed for that purpose. </br>
a. Curver Intersector: a tool that will compute the intersections of the curves with a straight line that is parallel to either axis. </br>
b. "Tangent" Intersector: a similar tool but instead of the intersections with the curves, it is the intersections with lines resulting from the linearisation of a section of the curves.</br>
c. Fuction Applier: a tool that will apply a function or an operation to the data. Ex: mean, derivation, integration, maximum,...</br>

In addition, a linear regression can be performed on the results to deduce some tendancies or some correlations.

Note: If the figure has been saved in .fig format. It is possible to analyse it again with a tool accessible by clicking on the icon on the top left corner of the main application.




