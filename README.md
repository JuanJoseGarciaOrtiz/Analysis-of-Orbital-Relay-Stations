This code serves for analysis, design and optimization of relay station networks. Main scripts AnalyzeMission.m call a mission algorithm and postprocess it providing useful information on trajectories and degradation. Three Missions proposed:

- Mission00: single payload with direct definition.
- Mission01: single payload with estimated Hohmann arcs.
- Mission: multi-payload with arbitrary mission profile.


It is part of a wider project that includes case studies and algorithm design steps "Analysis of Orbital Relay Stations for Orbital Energy Accumulation" (Bachelor Thesis uc3m, Author: Juan José García Ortiz).

Folder structure:

ROOT<br>
|----README and LICENSE.<br>
|<br>
|----Main scripts: AnalyzeMission, AnalyzeMission00, AnalyzeMission01.<br>
|<br>
|----Files: Text files that can be read by several functions for user input.<br>
|<br>
|----UnitTesting: Text files and scripts that can run unit tests for some of the functions in the code, main script RunAllTests.m | runs them all.<br>
|<br>
|----Functions: subroutines.<br>
        |----BaseModel: Basic subroutines to model the core physics of the problem.<br>
        |       |<br>
	|	|----MathematicalExpression: Lengthy expressions for other subroutines.<br>
	|	|<br>
	|	|----PaylaodOperations: Functions that specifically tackle operations between payloads and stations.<br>
	|	|<br>
	|	|----PlottingTools: Some functions that can be called during post-processors to plot.<br>
	|<br>
	|----Mission: Subroutines specific only to Mission.m function.<br>
	|<br>
	|----Mission00: Subroutines specific only to Mission00.m function.<br>
	|<br>
	|----Mission01: Subroutines specific only to Mission01.m function.<br>
	|<br>
	|----Design: Tools to design and optimize the performance of network and missions.<br>
	|	|<br>
	|	|----MissionDesign: Subroutines and main script to run the genetic algorithm mission optimizer.<br>
	|	|<br>
	|	|----NetworkDesign: Station spacing scripts according to different criterions.<br>
