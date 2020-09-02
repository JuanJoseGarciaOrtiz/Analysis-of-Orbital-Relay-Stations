%Solves and post-processes mission requested. 
%       Mission input can be loaded from data struct or as read from file
%       using ReadMissionData.m       

clc
clear
close all

%Add to path
addpath(genpath('Files'));
addpath(genpath('Functions'));
addpath(genpath('UnitTesting'));

% Preferences
displayImpactPlots = 1;
%% Data input
%Load mission data
InputData = ReadMissionData('MissionInputFile.txt');
%load('InputData.mat');
%load('InputOpt1.mat');

%Load Station data
[Network,n_stations] = ReadStationData('RelayStationsInput.txt');

%% Fucntion call
[Output,Event] = Mission(InputData,Network,n_stations);

Stations = Output.Stations;
Payloads = Output.Payloads;
configuration = Output.configuration;
n_stations = numel(Stations);
n_payloads = numel(Payloads);
n_events = numel(Event);

%% Post-process
% Assess station impact
StationImpact(n_stations).Event(n_events) = struct('r',0,'v_minus',zeros(1,3),'v_plus',zeros(1,3),'a_minus',0,'a_plus',0,'e_minus',0,'e_plus',0,'isActive',0,'v_rel',zeros(1,3));
for j = 1:n_stations
    for i = 1:n_events
        i_plus = Event(i).LastElement+1;
        i_minus = Event(i).LastElement;
        DummyImpact.r = Stations(j).r(i_minus,:);
        DummyImpact.v_minus = Stations(j).v(i_minus,:);
        DummyImpact.v_plus = Stations(j).v(i_plus,:);
        [~,~,~,~,~,~,DummyImpact.a_minus,DummyImpact.e_minus] = rv2COE(DummyImpact.r,DummyImpact.v_minus,configuration.mu);
        [~,~,~,~,~,~,DummyImpact.a_plus,DummyImpact.e_plus] = rv2COE(DummyImpact.r,DummyImpact.v_plus,configuration.mu);
        DummyImpact.isActive = 0;
        DummyImpact.v_rel = NaN;
        if strcmp(Event(i).type,'Ejection')
            if Event(i).CurrentStation == j
                DummyImpact.v_rel = Payloads(Event(i).Payload).v(i_plus,:) - DummyImpact.v_minus;
                DummyImpact.isActive = 1;
            end
        elseif strcmp(Event(i).type,'Attachment') && Event(i).TargetStation == j
            DummyImpact.v_rel = DummyImpact.v_plus - Payloads(Event(i).Payload).v(i_minus,:);
            DummyImpact.isActive = 1;
        end
        StationImpact(j).Event(i) = DummyImpact;
    end
end
clear('i_plus');clear('i_minus')

%% Figures
% Full mission
figure
hold on
for i = 1:n_stations
    plot3(Stations(i).r(:,1),Stations(i).r(:,2),Stations(i).r(:,3),'k')
end
axis image
for i = 1:n_payloads
    plot3(Payloads(i).r(:,1),Payloads(i).r(:,2),Payloads(i).r(:,3))
end
plot3(0,0,0,'o')
hold off

% Station impact (COE)
if displayImpactPlots
    for i = 1:n_stations
        x_dummy = [0,1:n_events];
        a_dummy = [StationImpact(i).Event(1).a_minus,1:n_events];
        e_dummy = [StationImpact(i).Event(1).e_minus,1:n_events];
        for j = 1:n_events
            a_dummy(j+1) = StationImpact(i).Event(j).a_plus;
            e_dummy(j+1) = StationImpact(i).Event(j).e_plus;
        end
        a_var = (a_dummy-a_dummy(1))./a_dummy;
        figure
        stairs(x_dummy,a_var)
        hold on
        stairs(x_dummy,e_dummy)
        hold off
        legend('Semimajor axis relative variation','Eccentricity')
        lim = 1.2*max(max(max(a_var),max(e_dummy)),0.01);
        axis([0 n_events -lim lim])
        s = sprintf('COE variation of Station %i',i);
        title(s)
        xlabel('Event number')
    end
    clear('x_dummy'); clear('a_dummy'); clear('e_dummy'); clear('s'); clear('a_var'); clear('lim');clear('DummyImpact')
end
%% Display
fprintf('\n\n\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++')
fprintf('\n++++++++++++++++++++++++++STATION IMPACT++++++++++++++++++++++++++\n')
for i = 1:n_events
    fprintf('||Event: %i||   Type: %s   t = %.2f s\n',i,Event(i).type,Event(i).time)
    if strcmp(Event(i).type,'Ejection')
        fprintf('Payload: %i  -->  Station: %i\n',Event(i).Payload,Event(i).CurrentStation)
        active = Event(i).CurrentStation;
    elseif strcmp(Event(i).type,'Attachment')
        fprintf('Payload: %i  -->  Station: %i\n',Event(i).Payload,Event(i).TargetStation)
        active = Event(i).TargetStation;
    end
    fprintf('r =        [%.2f,%.2f,%.2f] km\n',StationImpact(active).Event(i).r(1),StationImpact(active).Event(i).r(2),StationImpact(active).Event(i).r(3))
    fprintf('v_minus =  [%.4f,%.4f,%.4f] km/s\n',StationImpact(active).Event(i).v_minus(1),StationImpact(active).Event(i).v_minus(2),StationImpact(active).Event(i).v_minus(3))
    fprintf('v_plus =   [%.4f,%.4f,%.4f] km/s\n',StationImpact(active).Event(i).v_plus(1),StationImpact(active).Event(i).v_plus(2),StationImpact(active).Event(i).v_plus(3))
    fprintf('a_minus = %.2f            a_plus = %.2f\n',StationImpact(active).Event(i).a_minus,StationImpact(active).Event(i).a_plus)
    fprintf('e_minus = %.6f            e_plus = %.6f\n',StationImpact(active).Event(i).e_minus,StationImpact(active).Event(i).e_plus)
    fprintf('v_rel = %.4f\n',norm(StationImpact(active).Event(i).v_rel))
    fprintf('------------------------------------------------------------------\n')
end
fprintf('\n\n\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n')
cost_xi = 0;
cost_e = 0;
cost_aps = 0;
for i = 1:n_stations
    a0 = Network(i).a; af = StationImpact(i).Event(end).a_plus;
    e0 = Network(i).e; ef = StationImpact(i).Event(end).e_plus;
    xi0 = -configuration.mu/(2*a0); xif = -configuration.mu/(2*af);
    rp0 = a0*(1-e0); rpf = af*(1-ef);
    ra0 = a0*(1+e0); raf = af*(1+ef); 
    fprintf('------------Station %i------------\n',i)
    fprintf('a: %.2f km ---> %.2f km\n',a0,af)
    fprintf('e: %.6f  ---> %.6f\n',e0,ef)
    fprintf('xi: %.5f km^2/s^2 ---> %.5f km^2/s^2\n',xi0,xif)
    fprintf('rp: %.2f km ---> %.2f km\n',rp0,rpf)
    fprintf('ra: %.2f km ---> %.2f km\n',ra0,raf)
    cost_xi = cost_xi + (xif-xi0)^2;
    cost_e = cost_e + (ef-e0)^2;
    cost_aps = cost_aps + (rp0-rpf)^2 + (ra0-raf)^2;
end
cost_xi = sqrt(cost_xi);
cost_e = sqrt(cost_e);
cost_aps = sqrt(cost_aps);
%% Var clear
clear('i'); clear('j');clear('a0');clear('af');clear('e0');clear('ef');clear('xi0');clear('xif');clear('rp0');clear('rpf');clear('ra0');clear('raf');