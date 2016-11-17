%
% Burak Himmetoglu
% bhimmetoglu@ucsb.edu
% 11-10-2016
%
% Monte Carlo integral (spmd version)
% --------------------------------------------------------------------------------

%% Parallel Monte Carlo integral
maxNumCompThreads(4);

% Number of simulations
nSim = 1e+5; 

% Number of Dimensions
nDim = 10;

% Start clock
tic

% Run simulations
z=0;
s2=0;

% Start parallel region: Each lab will compute nSim times 
spmd
  for i = 1:nSim
	[v1, v2] = monteCarlo(nDim);
	z = z + v1;
	s2 = s2 + v2;
  end
  fprintf (' Lab %d obtained: %f, %f\n', labindex, z, s2 );
end
% End parallel region

% Start parallel region: Reduce the values
spmd
  tot_z = gplus( z ) / numlabs;
  tot_s2 = gplus( s2 ) / numlabs;
end
% End parallel region

% Average
intVal = tot_z{1}/nSim;
intErr = sqrt(tot_s2{1}/nSim - intVal^2) / sqrt(nSim);

% End clock
toc

% Print
fprintf('---- Monte Carlo integration ----\n');
fprintf(' Calculated Value, Error: %f, %f \n', intVal, intErr);
fprintf(' Exact result: %f \n', exact(10,1)); 
