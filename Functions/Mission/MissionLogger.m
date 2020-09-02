function MissionLogger(fname,logCase,log,display)
% Open file
fid = fopen(fname,'a');

% Evaluate case and information to log
if strcmp(logCase,'EventPosition')
    if log.valid
        string = sprintf('Attachment of payload %i to station %i successful to precision.\nr_target = [%f %f %f]\nr_actual = [%f %f %f]\n',...
            log.Event.Payload,log.Event.TargetStation,log.r_target(1),log.r_target(2),log.r_target(3),log.r_actual(1),log.r_actual(2),log.r_actual(3));
    else
        string = sprintf('Attachment of payload %i to station %i unsuccessful to precision.\nr_target = [%f %f %f]\nr_actual = [%f %f %f]\n',...
            log.Event.Payload,log.Event.TargetStation,log.r_target(1),log.r_target(2),log.r_target(3),log.r_actual(1),log.r_actual(2),log.r_actual(3));
    end
elseif strcmp(logCase,'EventVelocity')
    
elseif strcmp(logCase,'Iteration')
    if log.converged
        string = sprintf('-End of iteration %i with all transfers converged to precision-\n',log.n_iterations);
    else
        string = sprintf('-End of iteration %i with one or more transfers unconverged-\n------------------------------------------------------------------\n',log.n_iterations);
    end
end

% Write in log
fprintf(fid,string);

% Close file
fclose(fid);

%Print to screen (on request)
if display
    fprintf(string)
end
end