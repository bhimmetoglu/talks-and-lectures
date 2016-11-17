%
% Burak Himmetoglu
% bhimmetoglu@ucsb.edu
% 11-10-2016
%
% Calculate pi
% --------------------------------------------------------------------------------

% Set maximum number of threads to use (recommended, but not required)
maxNumCompThreads(12);

% Number of divisions
n = 100000;
fprintf ( ' Estimate pi using %d points\n', n );

result = trapez ( n );

fprintf ( '  Pi estimate is %f\n', result );
fprintf ( '  Exact pi    is %f\n', pi );
fprintf ( '  Error is             %e\n', abs ( result - pi ) );

