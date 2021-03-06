%
%   This example follows a similar design as already done in
%   Example 9-14, but in addition to the requirements of 
%   gain and noise figure, a constant VSWRin=1.5 is added 
% 
%   Copyright (c) 1999 by P.Bretchko and R.Ludwig
%   "RF Circuit Design: Theory and Practice"
%
close all; % close all opened graphs
clear all; % clear all variables

smith_chart; % create a Smith Chart

global Z0;
set_Z0(50);

% define the S-parameters of the transistor
s11=0.3*exp(j*(+30)/180*pi);
s12=0.2*exp(j*(-60)/180*pi);
s21=2.5*exp(j*(-80)/180*pi);
s22=0.2*exp(j*(-15)/180*pi);

% noise parameters of the transistor
Fmin_dB=1.5
Fmin=10^(Fmin_dB/10);
Rn=4;
Gopt=0.5*exp(j*45/180*pi);

s_param=[s11,s12;s21,s22];

% check stability
[K,delta] = K_factor(s_param)

% compute a noise circle
Fk_dB=1.6; % desired noise performance
Fk=10^(Fk_dB/10);

Qk=abs(1+Gopt)^2*(Fk-Fmin)/(4*Rn/Z0); % noise circle parameter
dfk=Gopt/(1+Qk); % circle center location
rfk=sqrt((1-abs(Gopt)^2)*Qk+Qk^2)/(1+Qk); % circle radius

%plot a noise circle
a=[0:360]/180*pi;
hold on;
plot(real(dfk)+rfk*cos(a),imag(dfk)+rfk*sin(a),'b','linewidth',2);
text(real(dfk)-0.1,imag(dfk)+rfk+0.08,...
   strcat('\bfF_k=',sprintf('%g',Fk_dB),'dB'));

% specify the goal gain
G_goal_dB=8;
G_goal=10^(G_goal_dB/10);

% find constant operating power gain circles
delta=det(s_param);
go=G_goal/abs(s21)^2; % normalized gain
dgo=go*conj(s22-delta*conj(s11))/(1+go*(abs(s22)^2-abs(delta)^2)); % center

rgo=sqrt(1-2*K*go*abs(s12*s21)+go^2*abs(s12*s21)^2);
rgo=rgo/abs(1+go*(abs(s22)^2-abs(delta)^2)); % radius

% map a constant gain circle into the Gs plane
rgs=rgo*abs(s12*s21/(abs(1-s22*dgo)^2-rgo^2*abs(s22)^2));
dgs=((1-s22*dgo)*conj(s11-delta*dgo)-rgo^2*conj(delta)*s22)/(abs(1-s22*dgo)^2-rgo^2*abs(s22)^2);

% plot constant gain circle in the Smith Chart
hold on;
plot(real(dgs)+rgs*cos(a),imag(dgs)+rgs*sin(a),'r','linewidth',2);
text(real(dgs)-0.1,imag(dgs)-rgs-0.05,...
   strcat('\bfG=',sprintf('%g',G_goal_dB),'dB'));

% choose a source reflection coefficient Gs
Gs=dgs+j*rgs;

% find the corresponding GL
GL=(s11-conj(Gs))/(delta-s22*conj(Gs));

% find the actual noise figure
F=Fmin+4*Rn/Z0*abs(Gs-Gopt)^2/(1-abs(Gs)^2)/abs(1+Gopt)^2;
% print out the actual noise figure
Actual_F_dB=10*log10(F)

% find the input and output reflection coefficients
Gin=s11+s12*s21*GL/(1-s22*GL);
Gout=s22+s12*s21*Gs/(1-s11*Gs);

% find the VSWRin and VSWRout
Gimn=abs((Gin-conj(Gs))/(1-Gin*Gs));
Gomn=abs((Gout-conj(GL))/(1-Gout*GL));

VSWRin=(1+Gimn)/(1-Gimn) % VSWRin should be unity since we used 
                         % the constant operating gain approach
VSWRout=(1+Gomn)/(1-Gomn)

% specify the desired VSWRin
VSWRin=1.5;

% find parameters for constant VSWR circle
Gimn=(1-VSWRin)/(1+VSWRin)
dvimn=(1-Gimn^2)*conj(Gin)/(1-abs(Gimn*Gin)^2); % circle center
rvimn=(1-abs(Gin)^2)*abs(Gimn)/(1-abs(Gimn*Gin)^2); % circle radius

% plot VSWRin=1.5 circle in the Smith Chart
plot(real(dvimn)+rvimn*cos(a),imag(dvimn)+rvimn*sin(a),'g','linewidth',2);
text(real(dvimn)-0.15,imag(dvimn)+rvimn+0.05,...
      strcat('\bfVSWR_{in}=',sprintf('%.1g',VSWRin)));
   
   % print -deps 'fig9_19.eps'  % Smith chart

% plot a graph of the output VSWR as a function 
% of the Gs position on the constant VSWRin circle   
Gs=dvimn+rvimn*exp(j*a); 
Gout=s22+s12*s21*Gs./(1-s11*Gs);

% find the reflection coefficients at the input and output matching networks
Gimn=abs((Gin-conj(Gs))./(1-Gin*Gs));
Gomn=abs((Gout-conj(GL))./(1-Gout*GL));

% and find the corresponding VSWRs
VSWRin=(1+Gimn)./(1-Gimn);
VSWRout=(1+Gomn)./(1-Gomn);

figure; % open new figure for the VSWR plot
plot(a/pi*180,VSWRout,'r',a/pi*180,VSWRin,'b','linewidth',2);
legend('VSWR_{out}','VSWR_{in}');
title('Input and output VSWR as a function of \Gamma_S position');
xlabel('Angle \alpha, deg.');
ylabel('Input and output VSWRs');
axis([0 360 1.3 2.3])
% print -deps 'fig9_20.eps'

% choose a new source reflection coefficient
Gs=dvimn+rvimn*exp(j*85/180*pi);
% find the corresponding output reflection coefficient
Gout=s22+s12*s21*Gs./(1-s11*Gs);

% compute the transducer gain in this case
GT=(1-abs(GL)^2)*abs(s21)^2.*(1-abs(Gs).^2)./abs(1-GL*Gout).^2./abs(1-Gs*s11).^2;
GT_dB=10*log10(GT)

% find the input and output matching network reflection coefficients
Gimn=abs((Gin-conj(Gs))./(1-Gin*Gs));
Gomn=abs((Gout-conj(GL))./(1-Gout*GL));

% ... and find the corresponding VSWRs
VSWRin=(1+Gimn)./(1-Gimn)
VSWRout=(1+Gomn)./(1-Gomn)

% also compute the obtained noise figure
F=Fmin+4*Rn/Z0*abs(Gs-Gopt)^2/(1-abs(Gs)^2)/abs(1+Gopt)^2;
F_dB=10*log10(F)

