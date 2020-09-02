function Event = SetTarget_r(Stations,Event)
for i = 1:numel(Event)
    %Find station location at attachment timestamps
    if strcmp(Event(i).type,'Attachment')
        target_r = Stations(Event(i).TargetStation).r(Event(i).LastElement,:);
        TargetSet = 0;
        %Assign target r to corresponding ejection event.
        j = i;
        while ~TargetSet
            j = j-1;
            if j == 0
                error('Unable to find corresponding ejection to an attachment event')
            end
            if strcmp(Event(j).type,'Ejection') && Event(j).Payload == Event(i).Payload
                Event(j).Target_r = target_r;
                TargetSet = 1;
            end
        end
    end
end
end