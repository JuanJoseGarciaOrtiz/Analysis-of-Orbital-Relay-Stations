function InputData = ReadMission00Data(InputFileName)
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

%Number of operations
n_operations = InputData.FinalStation - InputData.InitialStation;

%Preallocate
InputData.WaitingTime = zeros(1,n_operations);
InputData.TimeOfFlight = zeros(1,n_operations);

for i = 1:n_operations
    fgetl(fid); fscanf(fid,'\n'); %Read separator
    
    %Read Waiting time pre operation i
    fgetl(fid); fscanf(fid,'\n');
    InputData.WaitingTime(i) = fscanf(fid,'%f');
    
    %Read Time of Flight for operation i
    fgetl(fid); fscanf(fid,'\n');
    InputData.TimeOfFlight(i) = fscanf(fid,'%f');
end
fclose(fid);
end