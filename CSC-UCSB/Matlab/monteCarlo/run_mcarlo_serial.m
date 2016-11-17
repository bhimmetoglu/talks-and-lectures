%
% Burak Himmetoglu
% bhimmetoglu@ucsb.edu
% 11-10-2016
%
% Monte Carlo integral (serial version)
% --------------------------------------------------------------------------------

%% Serial Monte Carlo integral

% Number of simulations
nSim = 1e+5; 

% Number of Dimensions
nDim = 10;

% Start clock
tic

% Run simulations
z=0;
s2=0;
for i = 1:nSim
	[v1, v2] = monteCarlo(10);
	z = z + v1;
	s2 = s2 + v2;
end

% Average
intVal = z/nSim;
intErr = sqrt(s2/nSim - intVal.^2) / sqrt(nSim);

% End clock
toc

% Print
fprintf('---- Monte Carlo integration ----\n');
fprintf(' Calculated Value, Error: %f, %f \n', intVal, intErr);
fprintf(' Exact result: %f \n', exact(10,1)); 
