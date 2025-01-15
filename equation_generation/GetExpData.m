function [time_exp,Vout,Vin,Vratio_exp,Del_Vout,Del_Phase] = GetExpData(fileName,timeCorrection,coherent_in_phase,coherent_out_phase)

    fname = sprintf('%s.txt',fileName);
    file_exp = fopen(fname,'r');
   
    ExpData = fscanf(file_exp,'%12e %12e %12e %12e %12e',[5,1000]);
    time_exp = ExpData(1,:)';
    Vin = ExpData(2,:)'-coherent_in_phase;
    Vout = ExpData(3,:)'-coherent_out_phase;
   
   
    
    Vout1=Vout;   
    Vin1=Vin; 
    
   
    time_exp = time_exp + timeCorrection;
    
    
    [DD,II] = min(abs(time_exp));
    
    STD=std(Vout(4:(II-4)));
    
    MEAN = mean(Vout(4:(II-4)));
    
    autocorrection=1;
    
    if autocorrection==0
        
        % input the guess value here
    
    Theta= 0.0442;
    Vin_n = Vin*cos(Theta) - Vout*sin(Theta);
    Vout_n = Vout*cos(Theta) + Vin*sin(Theta);
    Vin = Vin_n;
    Vout = Vout_n;
    Vratio_exp = -Vin./Vout; 
    
    
    
    else
    
    Theta = fminsearch(@(X) phase_jump(Vout,Vin,time_exp,X),0);
    Theta1=Theta

    Vin_n = Vin*cos(Theta) - Vout*sin(Theta);
    Vout_n = Vout*cos(Theta) + Vin*sin(Theta);
    Vin = Vin_n;
    Vout = Vout_n;
    Vratio_exp = -Vin./Vout;
    
    [DD,II] = min(abs(time_exp));
    STD=std(Vout(2:(II-4)));
    
    MEAN = mean(Vout(2:2*II));
    
    for check = 1:2*II
        if abs(Vout(check)-MEAN) > 2.5*STD
            Vout(check) = MEAN;
        end
    end
    Theta = fminsearch(@(X) phase_jump(Vout,Vin,time_exp,X),0);

    Vin_n = Vin*cos(Theta) - Vout*sin(Theta);
    Vout_n = Vout*cos(Theta) + Vin*sin(Theta);
    Vin = Vin_n;
    Vout = Vout_n;
    
    STD=std(Vout(2:(II-4)));
    
    MEAN = mean(Vout(2:2*II));
    
    for check = 1:2*II
        if abs(Vout(check)-MEAN) > 2.5*STD
            Vout(check) = MEAN;
        end
    end
    Theta = fminsearch(@(X) phase_jump(Vout,Vin,time_exp,X),0);

    Vin_n = Vin*cos(Theta) - Vout*sin(Theta);
    Vout_n = Vout*cos(Theta) + Vin*sin(Theta);
    Vin = Vin_n;
    Vout = Vout_n;
    Vratio_exp = -Vin./Vout;
    
    end
    
    Del_Vin = max(Vin(2:2*II))-mean(Vin(2:II-2));
    Del_Vout = 1/sqrt((II-1))*std(Vout(2:(II-1)));
    Del_Phase = Del_Vout/Del_Vin;
    
%     fh = figure(1); % returns the handle to the figure object
%     clf;
%     set(fh,'Units','inches','Position', [1 3 5 3])
%     set(fh, 'color', 'white');
%     plot(time_exp(1:end),Vout(1:end),'k','LineWidth',2);
%     grid on
%     time_exp(II)
%     II
%     length(time_exp)
%     [ time_exp(1) time_exp(2*II-2)  1.3*Vout(1) .7*Vout(1)]
%     axis([ time_exp(1) time_exp(2*II-2)  1.1*min(Vout) 1.1*max(Vout)])
%     axis auto-y
%     xlabel('t (ps)')
%     ylabel('Vout');
% 
%     set(gcf, 'PaperPositionMode', 'auto');
%     fname = sprintf('%s_%s','Vout',fileName);
%     print('-dpng',fname);
      %plot the initial uncorrected vout
     fh = figure(101); % returns the handle to the figure object
    clf;
    set(fh,'Units','inches','Position', [1 3 5 3]);
    set(fh, 'color', 'white');
    plot(time_exp(1:end),Vout1(1:end),'k','LineWidth',2);
    grid on
    time_exp(II);
    II;
    length(time_exp);
    [ time_exp(1) time_exp(2*II-2)  1.3*Vout1(1) .7*Vout1(1)];
    axis([ time_exp(1) time_exp(2*II-2)  1.1*min(Vout1) 1.1*max(Vout1)])
    axis auto-y
    xlabel('t (ps)')
    ylabel('Vout uncorrected');
    
     fh = figure(102); % returns the handle to the figure object
    clf;
    set(fh,'Units','inches','Position', [1 3 5 3]);
    set(fh, 'color', 'white');
    plot(time_exp(1:end),Vin1(1:end),'k','LineWidth',2);
    grid on
    time_exp(II);
    II;
    length(time_exp);
    [ time_exp(1) time_exp(2*II-2)  1.3*Vin1(1) .7*Vin1(1)];
    axis([ time_exp(1) time_exp(2*II-2)  1.1*min(Vin1) 1.1*max(Vin1)])
    axis auto-y
    xlabel('t (ps)')
    ylabel('Vin uncorrected');
    
%      fh = figure(103); % returns the handle to the figure object
%     clf;
%     set(fh,'Units','inches','Position', [1 3 5 3]);
%     set(fh, 'color', 'white');
%     plot(time_exp(1:end),Vinsys(1:end),'k','LineWidth',2);
%     grid on    
%     [ time_exp(1) time_exp(end)  1.3*Vin1(1) .7*Vin1(1)];
%     axis([ time_exp(1) time_exp(end)  1.1*min(Vin1) 1.1*max(Vin1)])
%     axis auto-y
%     xlabel('t (ps)')
%     ylabel('Vout symmetric sum');
    
        
      
    
    % corrected Vout
    
    
    fh = figure(1); % returns the handle to the figure object
    clf;
    set(fh,'Units','inches','Position', [1 3 5 3])
    set(fh, 'color', 'white');
    plot(time_exp(1:end),Vout(1:end),'k','LineWidth',2);
    grid on
    time_exp(II);
    II;
    length(time_exp);
    [ time_exp(1) time_exp(2*II-2)  1.3*Vout(1) .7*Vout(1)];
    axis([ time_exp(1) time_exp(2*II-2)  1.1*min(Vout) 1.1*max(Vout)])
    axis auto-y
    xlabel('t (ps)')
    ylabel('Vout');   
    
    
    

    set(gcf, 'PaperPositionMode', 'auto');
    fname = sprintf('%s_%s','Vout',fileName);
    print('-dpng',fname);
    
    
    
    CorrectedExpDataFileName = sprintf('%s%s.txt','CorrectedExpData_',fileName);    
fid1 = fopen(CorrectedExpDataFileName,'w'); 
for j=1:length(time_exp)
fprintf(fid1,'\n  %6f %6f %6f %6f',time_exp(j),Vin(j),Vout(j),Vratio_exp(j)); 
end
fclose(fid1);

 
end