%Solves and post-processes prototype mission 00. 
%       Mission input can be loaded from data struct or as read from file
%       using ReadMission00Data.m       

clc
clear
close all

%Add to path
addpath(genpath('Files'));
addpath(genpath('Functions'));
addpath(genpath('UnitTesting'));

mu = 3.986*10^5; %km^3/s^2

InputData = ReadMission00Data('Mission00InputFile.txt');
[Network,n_stations] = ReadStationData('RelayStationsInput.txt');
Mission00_results = Mission00(InputData,Network,n_stations,mu);

n_operations = Mission00_results.input.FinalStation - Mission00_results.input.InitialStation;
n_stations = numel(Mission00_results.output.COE);


%% TABLES
%Table1
Rows = cell(1,2*n_stations);
cont = 1;
colDummy = zeros(2*n_stations,1);
Rows{cont} = 'timestamp';
for i = 1:n_stations
    cont = cont + 1;
    Rows{cont} = sprintf('S%i a',i);
    colDummy(cont) = Mission00_results.output.COE(i).initial.a;
    cont = cont + 1;
    Rows{cont} = sprintf('S%i e',i);
    colDummy(cont) = Mission00_results.output.COE(i).initial.e;
%     cont = cont + 1;
%     Rows{cont} = sprintf('S%i u',i);
end
clear cont

t_dummy = table(colDummy,'VariableNames',{sprintf('t%i',0)},'RowNames',Rows);


time = 0;
for j = 1:n_operations
    %Waiting time
    cont = 1;
    time = time + Mission00_results.input.WaitingTime(j);
    colDummy(cont) = time;
    for i = 1:n_stations
        [~,~,~,~,~,~,a,e] = rv2COE(Mission00_results.output.Station(i).r(time+1,:),Mission00_results.output.Station(i).v(time+1,:),mu);
        cont = cont + 1;
        colDummy(cont) = a;
        cont = cont + 1;
        colDummy(cont) = e;
    end
    t1 = table(colDummy,'VariableNames',{sprintf('t%i',2*j-1)},'RowNames',Rows);
    
    %Time of flight
    cont = 1;
    time = time + Mission00_results.input.TimeOfFlight(j);
    colDummy(cont) = time;
    for i = 1:n_stations
        cont = cont + 1;
        colDummy(cont) = Mission00_results.output.COE(i).Operation(j).a;
        cont = cont + 1;
        colDummy(cont) = Mission00_results.output.COE(i).Operation(j).e;
    end
    t2 = table(colDummy,'VariableNames',{sprintf('t%i',2*j)},'RowNames',Rows);
    
    t_dummy = [t_dummy t1 t2];
end
T = t_dummy;
fprintf('Semi-major axis (km) and eccentricity at each critical timestamp:\n')
disp(T)
clear cont
clear a
clear e
clear t1
clear t2
clear colDummy
clear time
clear Rows

%Table2
timeSpots = zeros(2,n_operations);
Deltav.WaitingTime = zeros(n_operations,3);
Deltav.TimeOfFlight = zeros(n_operations,3);
time = 0;
for j = 1:n_operations
    time = time + Mission00_results.input.WaitingTime(j);
    Deltav.WaitingTime(j,:) = Mission00_results.output.Payload.v(time+1,:) - Mission00_results.output.Payload.v(time,:);
    timeSpots(1,j) = time;
    time = time + Mission00_results.input.TimeOfFlight(j);
    Deltav.TimeOfFlight(j,:) = Mission00_results.output.Payload.v(time+1,:) - Mission00_results.output.Payload.v(time,:);
    timeSpots(1,j) = time;
end
T2 = table([norm(Deltav.WaitingTime(1,:));norm(Deltav.TimeOfFlight(1,:))],'VariableNames',{sprintf('Operation%i',1)},'RowNames',{'Ejection' 'Attatchment'});

for j = 2:n_operations
    t_dummy = table([norm(Deltav.WaitingTime(j,:));norm(Deltav.TimeOfFlight(j,:))],'VariableNames',{sprintf('Operation%i',j)},'RowNames',{'Ejection' 'Attatchment'});
    T2 = [T2 t_dummy];
end
fprintf('Delta V of each operation (km/s):\n')
disp(T2)
clear time
clear t_dummy
%% PLOTS
figure
r = Mission00_results.output.Payload.r;

hold on
for i = 1:n_stations
    %Plot Initial orbits
    COE = Mission00_results.output.COE(i).initial;
    PlotOrbit3D(COE.type,COE.omega,COE.inc,COE.OMEGA,COE.a,COE.e,mu,1000)
    hline = findobj(gcf, 'type', 'line');
    set(hline(1),'LineStyle','--','Color','	#D3D3D3')
    %Plot Final orbits
    COE = Mission00_results.output.COE(i).final;
    PlotOrbit3D(COE.type,COE.omega,COE.inc,COE.OMEGA,COE.a,COE.e,mu,1000)
    hline = findobj(gcf, 'type', 'line');
    set(hline(1),'LineStyle','--','Color','#696969')
    %Plot actual trajectories
    plot3(Mission00_results.output.Station(i).r(:,1),Mission00_results.output.Station(i).r(:,2),Mission00_results.output.Station(i).r(:,3),'Color','k','LineWidth',2)
end
plot3(r(:,1),r(:,2),r(:,3),'Color','b','LineWidth',2)
plot3(0,0,0,'o')
axis image
xlabel('x ECI (km)')
ylabel('y ECI (km)')
hold off

%% DATA EXTRACTOR
extractData = 0;
if extractData && n_operations == 1
    %Dtheta = 180 - rad2deg((Network(InputData.InitialStation).u));
    Da1 = -(Network(InputData.InitialStation).a - Mission00_results.output.COE(InputData.InitialStation).Operation.a);
    Da1_rel = Da1/Network(InputData.InitialStation).a;
    De1 = -(Network(InputData.InitialStation).e - Mission00_results.output.COE(InputData.InitialStation).Operation.e);
    Da2 = -(Network(InputData.FinalStation).a - Mission00_results.output.COE(InputData.FinalStation).Operation.a);
    Da2_rel = Da2/Network(InputData.FinalStation).a;
    De2 = -(Network(InputData.FinalStation).e - Mission00_results.output.COE(InputData.FinalStation).Operation.e);
    ExtractedData = sprintf('%i\t%i\t%.2f\t%.6f\t%.6f\t%.2f\t%.6f\t%.6f\t%.5f\t%.5f',InputData.WaitingTime,InputData.TimeOfFlight,...
        Da1,Da1_rel,De1,Da2,Da2_rel,De2,norm(Deltav.WaitingTime),norm(Deltav.TimeOfFlight))
end