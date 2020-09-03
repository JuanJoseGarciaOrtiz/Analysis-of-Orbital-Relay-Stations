This code serves for analysis, design and optimization of relay station networks. Main scripts AnalyzeMission.m call a mission algorithm and postprocess it providing useful information on trajectories and degradation. Three Missions proposed:

- Mission00: single payload with direct definition.
- Mission01: single payload with estimated Hohmann arcs.
- Mission: multi-payload with arbitrary mission profile.

It is part of a wider project that includes case studies and algorithm design steps "Analysis of Orbital Relay Stations for Orbital Energy Accumulation" (Bachelor Thesis uc3m, Author: Juan José García Ortiz)

INSTALLATION:
All files and folders in the root should be added to MATLAB path.

DEPENDENCIES:
MATLAB release 2020a (or more recent) is required to run all features of the code.
The project relies on additional MATLAB packages such as the Optimization Toolbox and the Global Optimization Toolbox.

QUICK USAGE GUIDE:
Input parameters for the different missipns can be tuned in their respective input file.
Main scripts have already built in post-processing tools that will print impact reports and plots directly.
Network and Mission design tools such as the ga.m optimizer are included in the "Design" folder and can be run and tuned in their respective main scripts.

ACKNOWLEDGEMENTS:
This code is the result of a year work Bachelor Thesis and posted publicly so that it can be useful for other people. It is kindly requested that you cite it if you use it.
The Bachelor Thesis was done under the supervision and tutoring of Mario Merino Martinez.


FOLDER STRUCTURE:
ROOT
|----README and LICENSE.
|
|----Main scripts: AnalyzeMission, AnalyzeMission00, AnalyzeMission01.
|
|----Files: Text files that can be read by several functions for user input.
|
|----UnitTesting: Text files and scripts that can run unit tests for some of the functions in the code, main script RunAllTests.m | runs them all.
|
|----Functions: subroutines
	|
	|----BaseModel: Basic subroutines to model the core physics of the problem
	|	|
	|	|----MathematicalExpression: Lengthy expressions for other subroutines.
	|	|
	|	|----PaylaodOperations: Functions that specifically tackle operations between payloads and stations.
	|	|
	|	|----PlottingTools: Some functions that can be called during post-processors to plot.
	|
	|----Mission: Subroutines specific only to Mission.m function.
	|
	|----Mission00: Subroutines specific only to Mission00.m function.
	|
	|----Mission01: Subroutines specific only to Mission01.m function.
	|
	|----Design: Tools to design and optimize the performance of network and missions.
	|	|
	|	|----MissionDesign: Subroutines and main script to run the genetic algorithm mission optimizer.
	|	|
	|	|----NetworkDesign: Station spacing scripts according to different criterions.
	
LICENSE
This software is released under the MIT License.
