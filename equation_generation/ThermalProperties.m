%Thermal properties of multilayer system.

%-------------TYPE THERMAL SYSTEM PARAMTERS HERE--------------
%Anticipated system properties (initial guess for fitting, if you do fitting/errorbar estimation)
[lambda C] = GetThermalProp(Temperature(count)+0.3,count);


%global h_f;
%t=[h_f(count) 1 104 1e9]*1e-9; 


% ("Al" thickness estimated at 84nm=81nm Al+3nm oxide, from picosecond acoustic)
%lambda(1)=10*lambda(2); %top 1nm 10X the rest of layer (simulates absorbtion)
%C(1)=10*C(2); %top 1nm 10X rest of layer

eta=ones(1,numel(lambda)); %isotropic layers, eta=kx/ky;


f=Freq(count)*1e6; %laser Modulation frequency, Hz

r_pump=w0(count)*1e-6;; %pump 1/e^2 radius, m
r_probe=r_pump; %probe 1/e^2 radius, m
tau_rep=1/80e6; %laser repetition period, s

A_pump=30e-3; %laser power (Watts) . . . only used for amplitude est.
TCR=1e-4; %coefficient of thermal reflectance . . . only used for amplitude est.

nnodes = 35; %this is the number of nodes used for numerical integration. (DEFAULT=35)  
%35 nodes gives more than enough accuracy, even for extreme cases such as
%graphite with a diffraction limited spot size...
%(more than 5 digits of Vin,Vout precision), but if you want speed at the
%expense of some precision, this gives you the option. CHANGE WITH CARE!

%------------- THERMAL SYSTEM PARAMTERS END HERE--------------