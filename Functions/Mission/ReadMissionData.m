function InputData = ReadMissionData(InputFileName)
% Reads input file containing input data for Mission00
fid = fopen(InputFileName,'r');
fgetl(fid); fscanf(fid,'\n'); %Skip commented first line

%Read number of payloads
fgetl(fid); fscanf(fid,'\n');
n_payloads = fscanf(fid,'%d');
InputData.n_payloads = n_payloads;

%Preallocate
InputData.Payload(n_payloads).mass = 0;
InputData.Payload(n_payloads).InitialStation = 0;
InputData.Payload(n_payloads).n_operations = 0;

for i = 1:n_payloads
    fgetl(fid); fscanf(fid,'\n'); %Read separator
    
    %Read Payload mass
    fgetl(fid); fscanf(fid,'\n');
    InputData.Payload(i).mass = fscanf(fid,'%d');
    
    %Read Payload initial station
    fgetl(fid); fscanf(fid,'\n');
    InputData.Payload(i).InitialStation = fscanf(fid,'%d');
    
    %Read number of operations associated to payload i
    fgetl(fid); fscanf(fid,'\n');
    InputData.Payload(i).n_operations = fscanf(fid,'%d');
    
    %Preallocate
    InputData.Payload(i).Operation(InputData.Payload(i).n_operations).WaitingTime = 0;
    InputData.Payload(i).Operation(InputData.Payload(i).n_operations).TimeOfFlight = 0;
    InputData.Payload(i).Operation(InputData.Payload(i).n_operations).TargetStation = 0;
    
    for j = 1:InputData.Payload(i).n_operations
        fgetl(fid); fscanf(fid,'\n'); %Read separator
        
        %Read operation j waiting time
        fgetl(fid); fscanf(fid,'\n');
        InputData.Payload(i).Operation(j).WaitingTime = fscanf(fid,'%f');
        
        %Read operation j time of flight
        fgetl(fid); fscanf(fid,'\n');
        InputData.Payload(i).Operation(j).TimeOfFlight = fscanf(fid,'%f');
        
        %Read operation j time of flight
        fgetl(fid); fscanf(fid,'\n');
        InputData.Payload(i).Operation(j).TargetStation = fscanf(fid,'%d');
    end
end
fclose(fid);
end