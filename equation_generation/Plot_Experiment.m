%load experimental data
file_exp = fopen('Ta_NO_2x_2p01.dat','r');
ExpData = fscanf(file_exp,'%13e  ',[5,516]);

time_exp = ExpData(1,:);
Vratio_exp = ExpData(4,:);
Vout = ExpData(3,:);
Vin = ExpData(2,:);

%Set zero
[ymin,xx1] = min(Vin(1:40));
[ymax,xx2] = max(Vin(1:40));
yy = (ymax-ymin)/2;
t_ss = [-20:0.001:20];
Vin_cont = spline(time_exp,Vin,t_ss);
[C,I] = min(abs(Vin_cont-yy))
dx = -0;
time_exp = time_exp-dx; 

%Correct phase
Theta = fminsearch(@(X) phase_jump(Vout,Vin,time_exp,X),0)

Vin_n = Vin - Vout*Theta;
Vout_n = Vout + Vin*Theta;

fh = figure(1);
clf;
%set(fh,'Units','inches','Position', [1 1 5 3])
set(fh, 'color', 'white');
plot(time_exp,Vout_n,'k','LineWidth',2);
grid on
axis([ -20 40 -35 -20])
axis auto-y
xlabel('t (ps)')
ylabel('Vout');


Vratio_exp = abs(Vin_n./Vout_n);

fh = figure(2);
clf;
%set(fh,'Units','inches','Position', [6.5 1 5 3])
set(fh, 'color', 'white');

plot(time_exp,Vin_n,'k','LineWidth',3);

ylabel('Vin')
xlabel('t (ps)')

axis([-10 60 0 170])

hold on;
time =28;
plot([time time],[-1e6 1e6],'m');

time =time*2;
plot([time time],[-1e6 1e6],'m');

break;