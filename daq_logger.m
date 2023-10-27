global aline;
global outfile;

% Output file
outfile = strcat('data ', datestr(now, 'yyyymmdd_HHMMSS'), '.csv'); 
% Setup plot
cla()
aline = animatedline('Marker','.', 'MaximumNumPoints',100);
xlabel('Time (s)')
ylabel('Voltage(v)')

% Set up daq
%function f = daq_acquire_plot(device)
dq = daq("ni");
addinput(dq, "Dev1", "ai0", "Voltage");  % Acquisition channel
dq.Rate = 10;  % sampling rate

dq.ScansAvailableFcn = @(src,evt) plotDataAvailable(src, evt);
dq.ScansAvailableFcnCount = dq.Rate/5; % Redraw 5 times per seconds

% Duration of acquisition
%start(dq, "Duration", seconds(1))  % acquire for n seconds
start(dq, "Continuous")   % acquire indefinitely until user types stop(dq) 

disp(strcat('Saving data to file:  ', outfile))
disp('Type stop(dq) to stop acquisition')

function plotDataAvailable(src, ~)
    global aline
    global outfile
    [data, timestamps, ~] = read(src, src.ScansAvailableFcnCount, ...
        "OutputFormat", "Matrix");
    writematrix([timestamps, data],outfile,'WriteMode','append');
    addpoints(aline,timestamps,data);
end
