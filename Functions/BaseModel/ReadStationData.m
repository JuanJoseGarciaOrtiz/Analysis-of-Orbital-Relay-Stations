function [Network,n_stations] = ReadStationData(InputFileName)
% Reads input file containing initial data for base station network
fid = fopen(InputFileName,'r');
fgetl(fid); fscanf(fid,'\n'); %Skip commented first line


%Read number of stations in the network
fgetl(fid); fscanf(fid,'\n');
n_stations = fscanf(fid,'%d');

%Preallocate
Network = struct('type',cell(n_stations,1),'u',cell(n_stations,1),'omega',cell(n_stations,1),'theta',cell(n_stations,1),'i',cell(n_stations,1),'OMEGA',cell(n_stations,1),'a',cell(n_stations,1),'e',cell(n_stations,1));

for i = 1:n_stations
    fgetl(fid); fscanf(fid,'\n'); %Read separator
    
    %Read mass of the station
    fgetl(fid); fscanf(fid,'\n');
    Network(i).mass = fscanf(fid,'%d');
    
    %Read orbit type (0 for elliptic and 1 for circular)
    fgetl(fid); fscanf(fid,'\n');
    Network(i).type = fscanf(fid,'%d');
    
    if Network(i).type == 1
        Network(i).omega = NaN;
        Network(i).theta = NaN;
        
        %Read argument of latitude
        fgetl(fid); fscanf(fid,'\n');
        Network(i).u = deg2rad(fscanf(fid,'%f'));
        
        %Skip argument of periapsis
        fgetl(fid); fscanf(fid,'\n');
        fgetl(fid); fscanf(fid,'\n');
        
        %Skip initial true anomaly
        fgetl(fid); fscanf(fid,'\n');
        fgetl(fid); fscanf(fid,'\n');
        
        %Read Inclination
        fgetl(fid); fscanf(fid,'\n');
        Network(i).i = deg2rad(fscanf(fid,'%f'));
        
        %Read RAAN
        fgetl(fid); fscanf(fid,'\n');
        Network(i).OMEGA = deg2rad(fscanf(fid,'%f'));
        
        %Read Semi-major axis
        fgetl(fid); fscanf(fid,'\n');
        Network(i).a = fscanf(fid,'%f');
        
        %Read eccentricity
        fgetl(fid); fscanf(fid,'\n');
        Network(i).e = fscanf(fid,'%f');
    else
        Network(i).u = NaN;
        
        %Skip argument of latitude
        fgetl(fid); fscanf(fid,'\n');
        fgetl(fid); fscanf(fid,'\n');
        
        %Read argument of periapsis
        fgetl(fid); fscanf(fid,'\n');
        Network(i).omega = deg2rad(fscanf(fid,'%f'));
        
        %Read initial true anomaly
        fgetl(fid); fscanf(fid,'\n');
        Network(i).theta = deg2rad(fscanf(fid,'%f'));
        
        %Read Inclination
        fgetl(fid); fscanf(fid,'\n');
        Network(i).i = deg2rad(fscanf(fid,'%f'));
        
        %Read RAAN
        fgetl(fid); fscanf(fid,'\n');
        Network(i).OMEGA = deg2rad(fscanf(fid,'%f'));
        
        %Read Semi-major axis
        fgetl(fid); fscanf(fid,'\n');
        Network(i).a = fscanf(fid,'%f');
        
        %Read eccentricity
        fgetl(fid); fscanf(fid,'\n');
        Network(i).e = fscanf(fid,'%f');
    end
end
fclose(fid);
end