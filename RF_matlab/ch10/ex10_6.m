%
%   In this example we design an oscillator
%   using a dielectric resonator (DR)
% 
%   Copyright (c) 1999 by P.Bretchko and R.Ludwig
%   "RF Circuit Design: Theory and Practice"
%

close all; % close all opened graphs
clear all; % clear all variables

% define the S-paramters of the transistor at resonance frequency
s11=1.1*exp(j*(170)/180*pi);
s12=0.4*exp(j*(-98)/180*pi);
s21=1.5*exp(j*(-163)/180*pi);
s22=0.9*exp(j*(-170)/180*pi);

s=[s11,s12;s21,s22];

% plot stability circle
smith_chart;

input_stability(s,'r');

print -deps 'fig10_21.eps'

global Z0;
set_Z0(50);

% define oscillation frequency
f0=8e9;
w0=2*pi*f0;

% define parameters of the dielectric resonator
beta=7;
R=beta*2*Z0;
Qu=5e3;

% compute equivalent L and C
L=R/(Qu*w0);
C=1/(L*w0^2);

% find output reflection coefficient of the DR
Gout_abs=beta/(1+beta);
Gout_angle=-angle(s11)/pi*180;

% compute electrical length of the transmission line for the DR
theta0=-1/2*Gout_angle
Gout=Gout_abs*exp(j*Gout_angle*pi/180);

% find the output impedance of the DR
Zout=Z0*(1+Gout)/(1-Gout)

% find the equivalent capacitance (it will be necessary for 
% the computation of the oscillator without DR)
CC=-1/(w0*imag(Zout))

Rs=50;

% define the frequency for the plot
delta_f=0.05e9; % frequency range
f=f0-delta_f/2 : delta_f/100 : f0+delta_f/2;
w=2*pi*f;

if theta0<0
   theta0=360+theta0;
end;

theta=theta0*f/f0/180*pi;

% repeat the same computations as above, but for specified frequency range
Gs=(Rs-Z0)/(Rs+Z0);
G1=Gs*exp(-j*2*theta);
R1=Z0*(1+G1)./(1-G1);
Zd=1./(1/R+1./(j*w*L)+j*w*C);
R1d=R1+Zd;
G1d=(R1d-Z0)./(R1d+Z0);
G2=G1d.*exp(-j*2*theta);

% compute the output reflection coefficient (we have oscillations if |Gout|>1)
Gout=s22+s12*s21*G2./(1-s11*G2);

figure;
plot(f/1e9,abs(Gout),'b','linewidth',2);
title('Output reflection coefficient of the oscillator with DR');
xlabel('Frequency f, GHz');
ylabel('Output reflection coefficient |\Gamma_{out}|');
axis([7.975 8.025 0 14]);
%print -deps 'fig10_23a.eps'

% Redefine the frequency range (we have to increase it in order to
% be able to observe any variations in the response
delta_f=5e9; % frequency range
f=f0-delta_f/2 : delta_f/100 : f0+delta_f/2;
w=2*pi*f;

% Compute the output reflection coefficient of the oscillator
% but with DR replaced by a series combination of resistance and capacitance
ZZ2=real(Zout)+1./(j*w*CC);
GG2=(ZZ2-Z0)./(ZZ2+Z0);
GG=s22+s12*s21*GG2./(1-s11*GG2);

figure;
plot(f/1e9,abs(GG),'r','linewidth',2);
title('Output reflection coefficient of the oscillator without DR');
xlabel('Frequency f, GHz');
ylabel('Output reflection coefficient |\Gamma_{out}|');
%print -deps 'fig10_23b.eps'
