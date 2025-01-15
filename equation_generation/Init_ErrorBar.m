%InitializeErrorBar
%Initialize values

% lambda=[18 40 0.15 1.3 0.2 142]; %W/m-K
% C=[3.15 2.85 0.1 1.62 0.1 1.6]*1e6; %J/m^3-K
% t=[7.5 41.6 1 104 1 1e6]*1e-9; %m 



    C_consider=ones(length(C),1);
    L_consider=ones(length(C),1);
    t_consider=ones(length(C),1);
    r_probe_consider=1;
    r_pump_consider=1;
    phase_consider=1;
    CErr=zeros(length(C),length(Xguess));
    lambdaErr=zeros(length(lambda),length(Xguess));
    tErr=zeros(length(lambda),length(Xguess));
    r_probeErr=zeros(1,length(Xguess));
    r_pumpErr=zeros(1,length(Xguess));
    
    %define parameters NOT to consider in error analysis (saves time)
    t_consider(length(t))=0; %last layer is semi-inf
    t_consider(2)=0; %thermal interface conductance at fixed t/vary lambda
    %t_consider(5)=0; %thermal interface conductance at fixed t/vary lambda
    
        
    C_consider(2)=0; %thermal interface layer has no capacitance
    %C_consider(5)=0; %thermal interface layer has no capacitance
    
       
    L_consider(2)=0; %solving for this %<-------------COMMENT-if solving for only lambda(4)!  
    L_consider(3)=0;
  
    
        
    %define percent uncertainty in each layer/parameter
      Cperc_err=[0.02 0 0.02 0.02]; %percent uncertainty in specific heat %i.e. 0.02 -> 2% uncertainty
    lambdaperc_err=[0.1 0 0 0 ];% percent uncertainty in thermal conducitivyt
    tperc_err=[0.04 0 0.05 0 ];  % percent uncertainty in layer thickness
    r_err=0.05;  % percent uncertainty in beam radius
    radphase=0.002;  %phase error in degrees
    
    