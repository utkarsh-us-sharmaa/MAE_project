function [lambda C] = GetThermalProp(T,count);
%Thermal properties of multilayer system.

%-------------TYPE THERMAL SYSTEM PARAMTERS HERE--------------
%Anticipated system properties (initial guess for fitting, if you do
%fitting/errorbar estimation)

global Sub_C
global Sub_K

Sub_C = 1.6*ones(size(Freq));
Sub_K = 142*ones(size(Freq));



Al_C = 2.42;
Al_K = 160;

global Sub_C
global Sub_K
Substrate_C = Sub_C(count);
Substrate_K = Sub_K(count);

G = 0.2;  %0.2

lambda=[Al_K G 1.3 Substrate_K]; %W/m-K
C=[Al_C 0.1 1.62 Substrate_C]*1e6; %J/m^3-K
t=[123 1 104 1e9]*1e-9; % nm

% thickness is in Thermal Properties files

%------------- THERMAL SYSTEM PARAMTERS END HERE--------------
end