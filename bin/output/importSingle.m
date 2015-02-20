function  importSingle(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [VARNAME5,VARNAME6] = IMPORTFILE(FILENAME) Reads data from text file
%   FILENAME for the default selection.
%
%   [VARNAME5,VARNAME6] = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data
%   from rows STARTROW through ENDROW of text file FILENAME.
%
% Example:
%   [VarName5,VarName6] = importfile('swe_20150214_120553.txt',1, 201);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2015/02/14 12:06:38

%% Initialize variables.
delimiter = ',';
if nargin<=2
    startRow = 1;
    endRow = inf;
end

%% Format string for each line of text:
%   column3: double (%f)
%	column4: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%*s%*s%f%f%[^\n\r]';



%% Open the text file.
fileID = fopen(strcat(filename),'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
t_h = dataArray{:, 1};
eta_h = dataArray{:, 2};


hold on
plot(t_h,eta_h,'b')



%% analytical solution
lambda=20;
h=5;
g=9.80665;
c= sqrt((g*lambda/(2*pi))* tanh(2*pi*h/lambda));
a=0.1;
period=lambda/c


x= [0:0.1:20];
y=-a* cos((2*pi*9.9/lambda) + (2*pi*x/(lambda/c)));

plot(x,y,'k')
xlabel('time t [s]')
ylabel('water elevation eta [m]')
title('h=5 m')
xlim([0,14])


hold off
