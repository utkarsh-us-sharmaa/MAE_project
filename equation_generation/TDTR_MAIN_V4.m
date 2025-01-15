function TDTR_MAIN_V4(lambda, output_file_prefix)
    % clear all;
    % clc;
    % Ensure `lambda` is a numerical array
    if iscell(lambda)
        lambda = cell2mat(lambda);
    end

    % Ensure `output_file_prefix` is a string
    if iscell(output_file_prefix)
        output_file_prefix = char(output_file_prefix);
    end
    %%%%% f = 3.85 MHz
    FileNames = output_file_prefix; 

    %  9 layer configuration Al for inhomogenous 9 layers

    % lambda=[140 0.06 56.8889 73.7778 90.6667 107.5555 124.4444 0.1 10]; % thermal conductivity
    C = [2.42 0.1 0.734*3.26 0.734*3.26 0.734*3.26 0.734*3.26 0.734*3.26 0.1 1.6]*1e6;% heat capacity
    t=[25*6.4/2 1 80 80 80 80 80 1 1e9]*1e-9; % thickness
    f=3.85*1e6; %laser Modulation frequency, Hz + various freq...
    % % % 
    timeshift=0; %time shift alignment
    % % % 
    r_pump=11.098*1e-6; %%%% 0.98
    % % % 
    eta=[1 1 1 1 1 1 1 1 1]; %isotropic layers, eta=kx/ky;

    coherent_in_phase=0.15;
    coherent_out_phase=-4.3; %noise
    % 
    tau_rep=1/80e6; %laser repetition period, s (MHz)
    % 
    A_pump=30e-3; %laser power (Watts) . . . only used for amplitude est.
    A_probe=15e-3; %with chopper
    % 
    TCR=1e-4; %coefficient of thermal reflectance . . . only used for amplitude est.
    % 
    nnodes = 35; %this is the number of nodes used for numerical integration. (DEFAULT=35)  

    %choose time delays for Sensitivity plots (sensitivity calculation generally 60 points)
    tdelay=logspace(log10(100e-12),log10(3.6e-9),60)'; %vector of time delays (used to generate sensitivity plots)
    % if this tdelay is used for calculating the errors, make sure the points
    % are a lot, otherwise it will end up with large mistakes
    %Choose range of time delays to fit, sec (our stage)
    tdelay_min=100e-12;
    tdelay_max=3400e-12;
    % pump and probe radius + time delay, several freq data....

    r_probe=r_pump; %probe 1/e^2 radius, m

    % %------------- CALCULATE STEADY STATE HEATING--------------
    % absorbance = 0.12*1.08*0.9; %fraction of incident light absorbed at surface (metalabsorption 0.8 transmission of objective lens _ exp)
    % % 2X ~0.87, 5X~ 0.9, 10X ~0.80, 20X ~ 0.70
    % A_tot_powermeter = A_pump+2*A_probe; %incident light intensity, Watts % here should be pump power  (real power)
    % dT_SS = SS_Heating(0,lambda,C,t,eta,r_pump,r_probe,absorbance,A_tot_powermeter) %max steady state temperature rise
    % PP_Heating=absorbance*A_pump*2*tau_rep/(pi*r_pump^2)/(C(1)*t(1))

    %----------------------------------PROGRAM OPTIONS BEGIN--------
    %Generate Sensitivity Plots? (0 model )
    senseplot=0;
    %Import Data? 0 for no, 1 for yes
    importdata=0;
    %If so, which variable(s) are you fitting for?
    Xguess=[lambda(3), lambda(2)];%, lambda(3)]; %initial guess for solution, could be for simulated data (if nothing imported) or real da
    %if you change the lamda, you need change the fitting code TDTR_FIT
    %Calculate Errorbars? 0 for no, 1 for yes (takes longer) 
    ebar=0;
    % Want to save results?
    saveint=0;

    %----------------------------------PROGRAM OPTIONS END--------

    %---------------------ERRORBAR OPTIONS----------------------
    if ebar==1
    % Init_ErrorBar;
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
        t_consider(3)=0; %thermal interface conductance at fixed t/vary lambda
        %t_consider(5)=0; %thermal interface conductance at fixed t/vary lambda
        
            
        C_consider(3)=0; %thermal interface layer has no capacitance
        %C_consider(5)=0; %thermal interface layer has no capacitance
        
        
        L_consider(4)=0; %solving for this %<-------------COMMENT-if solving for only lambda(4)!  
        %L_consider(3)=0;
    
        
            
        %define percent uncertainty in each layer/parameter
        Cperc_err=[0.01 0 0.01 0 0.01 0]; %percent uncertainty in specific heat %i.e. 0.02 -> 2% uncertainty
        lambdaperc_err=[0.02 0 0.02 0.02 0 0];% percent uncertainty in thermal conducitivyt
        tperc_err=[0.01 0 0.01 0.01 0];  % percent uncertainty in layer thickness
        r_err=0.02;  % percent uncertainty in beam radius
        radphase=0.006;  %phase error in degrees
        
        
    end

    %-----------------Make sensitivity plots--------------
    [deltaR_data,ratio_data]=TDTR_REFL_V4(tdelay,TCR,tau_rep,f,lambda,C,t,eta,r_pump,r_probe,A_pump,nnodes);


    if senseplot==1
        TDTR_SensPlots_V4
    end

    %--------------Import Data---------------------------
    if importdata==1
        [tdelay_raw,Vout_raw,Vin_raw,ratio_raw,Del_Vout,Del_Phase] = GetExpData(FileNames,timeshift,coherent_in_phase,coherent_out_phase);
        tdelay_raw = tdelay_raw*1e-12;
        [DD,II] = min(abs(tdelay_raw-100e-12));
        Results_ratio = ratio_raw(II)
        pause(1);
        [tdelay_data,Vin_data] = extract_interior_V4(tdelay_raw,Vin_raw,tdelay_min,tdelay_max);
        [tdelay_data,Vout_data] = extract_interior_V4(tdelay_raw,Vout_raw,tdelay_min,tdelay_max);
        [tdelay_data,ratio_data] = extract_interior_V4(tdelay_raw,ratio_raw,tdelay_min,tdelay_max);
        
    CorrectedExpDataFileName = sprintf('%s%s.txt','Al_200_CorrectedExpData_',FileNames);    
    % fid1 = fopen(CorrectedExpDataFileName,'w'); 
    % for j=1:length(tdelay_raw)
    % fprintf(fid1,'\n  %6f %6f %6f %6f',tdelay_raw(j)/1e-12,Vin_raw(j),Vout_raw(j),ratio_raw(j)); 
    % end
    % fclose(fid1);
        
    %--------------Perform Fit (skips if no data imported)--------------------------
        Xsol=fminsearch(@(X) TDTR_FIT_V4(X,ratio_data,tdelay_data,TCR,tau_rep,f,lambda,C,t,eta,r_pump,r_probe,A_pump,nnodes),Xguess,optimset('TolX',1e-4))
        Xguess=Xsol;
        tdelay=tdelay_data;
        fprintf('Data fit completed\n')
    else
        [tdelay,Vin_data] = extract_interior_V4(tdelay,real(deltaR_data),tdelay_min,tdelay_max);
        [tdelay,Vout_data] = extract_interior_V4(tdelay,imag(deltaR_data),tdelay_min,tdelay_max);
        [tdelay,ratio_data] = extract_interior_V4(tdelay,ratio_data,tdelay_min,tdelay_max);
        Xsol = Xguess;
    end

    %--------------Compute Errorbars---------------------
    if ebar==1
        TDTR_Errorbars_V4
    end
    fprintf('Fitting Solution:\n')

    % 
    % Results_K = Xsol(1);
    % Results_G = Xsol(2);
    % lambda(4) = Xsol(1);
    % lambda(3) = Xsol(2);



    if importdata==1

    [Z,ratio_model]=TDTR_FIT_V4(Xsol,ratio_data,tdelay_data,TCR,tau_rep,f,lambda,C,t,eta,r_pump,r_probe,A_pump,nnodes);

    else

    [deltaR_data,ratio_model]=TDTR_REFL_V4(tdelay,TCR,tau_rep,f,lambda,C,t,eta,r_pump,r_probe,A_pump,nnodes);

    end


    CalcRatioFileName = sprintf('%s.txt', FileNames);
    fid2 = fopen(CalcRatioFileName,'w'); 
    for j=1:length(tdelay)
    fprintf(fid2,'\n  %6f %6f %6f %6f',tdelay(j)/1e-12,Vin_data(j),Vout_data(j),ratio_model(j)); 
    end
    fclose(fid2);


    % snrnumber = 35;

    % snr = abs(mean(Vout_raw(1:snrnumber))/(std(Vout_raw(1:snrnumber))))
    % CalcRatioFileName = sprintf('%s%s.txt','ModelRatio_',FileNames);
    % dlmwrite(CalcRatioFileName,[tdelay*1e12,ratio_model],'delimiter','\t')

    %----------------------------------------------------
    if saveint==1
        ResultsName = sprintf('%s%s.txt','Al_200_BestFitResults_',FileNames);
        save(ResultsName,'Xsol');
        fignum=203;
        figure(fignum)
        clf;
        semilogx(tdelay_data,ratio_model,'r-','LineWidth',2)
        hold on;
        plot(tdelay_data,ratio_data,'ok');
        xlabel({['time delay (s); ',num2str(Xsol(1)), ',', num2str(Xsol(2)), ',', num2str(round(snr))]},'FontSize',12)
        ylabel('Vratio','FontSize',18)
        %title('Data Fit')
        legend('Model','Experiment')
        legend boxoff
        set(gca,'FontSize',18)
        axis([min(tdelay_data) max(tdelay_data) 0 1.2*max([ratio_data;ratio_model])])
        FigureName = sprintf('%s%s.png','FIT_',FileNames);
        print(fignum,'-dpng',FigureName)
        
    FinalFileName = sprintf('%s%s.txt','Al_200_FinalFittingData_',FileNames);
    fid3 = fopen(FinalFileName,'w'); 
    for j=1:length(tdelay)
    fprintf(fid3,'\n  %8f %8f %8f ',tdelay_data(j)/1e-12,ratio_data(j),ratio_model(j)); 
    end
    fclose(fid3);

        
    end
    %----------------------------------------------------
    disp(['Output file saved as: ', CalcRatioFileName]);
    fprintf('Program Completed\n')
    beep;

