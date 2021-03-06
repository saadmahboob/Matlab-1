function Add_series_sc_stub(theta_deg,freq_0,line_Z0)
% this function adds a description of the short-circuit stub connected to the
% rest of the network in series
%
% USAGE:
% Add_series_sc_stub(45, 1e9, 75)
%                     |   |    |
%                     |   |    +---- characteristic impedance of the stub
%                     |   |
%                     |   +--------- frequency at which electrical length 
%                     |              of the transmission line is specified
%                     |
%                     +------------- electrical length of the stub (beta*length)
%

global rf_Network;

rf_Network=cat(2,rf_Network,[4;theta_deg;0;freq_0;line_Z0]);
