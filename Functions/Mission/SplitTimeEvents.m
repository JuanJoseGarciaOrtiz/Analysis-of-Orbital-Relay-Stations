function [Event,tspan] = SplitTimeEvents(Payload,n_payloads,configuration)
step = configuration.step;
epsilon = configuration.epsilon;
UnorderedEvent = struct('time',cell(n_payloads,1));
%Register events
i_cont = 0;
for i = 1:n_payloads
    accum_time = 0;
    CurrentDummy = Payload(i).InitialStation;
    for j = 1:Payload(i).n_operations
        
        %Ejection
        i_cont = i_cont + 1;
        accum_time = accum_time + Payload(i).Operation(j).WaitingTime;
        UnorderedEvent(i_cont).time = accum_time;
        UnorderedEvent(i_cont).Dt = Payload(i).Operation(j).TimeOfFlight;
        UnorderedEvent(i_cont).type = 'Ejection';
        UnorderedEvent(i_cont).Payload = i;
        UnorderedEvent(i_cont).CurrentStation = CurrentDummy;
        UnorderedEvent(i_cont).TargetStation = Payload(i).Operation(j).TargetStation;
        
        %Attatchment
        i_cont = i_cont + 1;
        CurrentDummy = Payload(i).Operation(j).TargetStation;
        accum_time = accum_time + Payload(i).Operation(j).TimeOfFlight;
        UnorderedEvent(i_cont).time = accum_time;
        UnorderedEvent(i_cont).type = 'Attachment';
        UnorderedEvent(i_cont).Payload = i;
        UnorderedEvent(i_cont).TargetStation = Payload(i).Operation(j).TargetStation;
    end
end

%Order Events in time
Event = UnorderedEvent;
flag = 1;
while flag
    flag = 0;
    for i = 2:i_cont
        if Event(i).time < Event(i-1).time
            flag = 1;
            DummyEvent = Event(i);
            Event(i) = Event(i-1);
            Event(i-1) = DummyEvent;
        end
    end
end

%Define time spans
numel_accum = 0;
tspan = zeros(0);
for i = 1:numel(Event)
    if i == 1
        Event(i).tspan = 0:step:Event(i).time;
        Event(i).FirstElement = 1;
    else
        Event(i).tspan = (Event(i-1).time + epsilon):step:Event(i).time;
        Event(i).FirstElement = numel_accum + 1;
    end
    if Event(i).tspan(end) ~= Event(i).time
        Event(i).tspan = [Event(i).tspan Event(i).time];
    end
    numel_accum = numel_accum + numel(Event(i).tspan);
    Event(i).LastElement = numel_accum;
    tspan = [tspan Event(i).tspan];
end
tspan = [tspan tspan(end)+epsilon];
end