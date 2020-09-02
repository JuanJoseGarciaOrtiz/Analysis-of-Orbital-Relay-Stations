function InputData = ReadMission01Data(InputFileName)
% Reads input file containing input data for Mission00
fid = fopen(InputFileName,'r');
fgetl(fid); fscanf(fid,'\n'); %Skip commented first line

%Read Payload mass
fgetl(fid); fscanf(fid,'\n');
InputData.PayloadMass = fscanf(fid,'%d');

%Read initial payload station
fgetl(fid); fscanf(fid,'\n');
InputData.InitialStation = fscanf(fid,'%d');

%Read final payload station
fgetl(fid); fscanf(fid,'\n');
InputData.FinalStation = fscanf(fid,'%d');

fclose(fid);
end