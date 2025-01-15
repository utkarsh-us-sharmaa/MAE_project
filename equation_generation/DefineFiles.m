
FileNames = {
'TDTR_311 nm SiO2_5X_18mW_1'
};

NumberOfFiles = length(FileNames);
Temperature = 295*ones(1,length(FileNames));
Freq = [9.8]; %in MHz
w0 = 10.7*ones(size(Freq));
%h_f = 123.46*ones(size(Freq));  % Al thickness

global Sub_C
global Sub_K

Sub_C = 1.6*ones(size(Freq));
Sub_K = 142*ones(size(Freq));

