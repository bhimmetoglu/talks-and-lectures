%
% Burak Himmetoglu
% bhimmetoglu@ucsb.edu
% 11-10-2016
%
% Trapezoidal rule using SPMD
% --------------------------------------------------------------------------------

function result = trapez(n)
% Function to calculate pi using the trapeziodal rule
% Work is divived across labs
%
% result = \int_0^1 1/(1+x^2) dx

%% Divide the [0,1] interval across labs. Each lab will have its own [loc_a,loc_b]

% Start parallel region
spmd
  loc_a = (labindex -1)/numlabs; % labindex & numlabs are variables generated once spmd is called
  loc_b = labindex / numlabs;
  fprintf('Lab %d integrates oves [%f, %f] \n', labindex, loc_a, loc_b);
end
% End parallel region

%% For each region [loc_a, loc_b] use trapeziodal rule to approximate the integral

% Start parallel region
spmd
  x = linspace(loc_a,loc_b,n); % Divide the local region into n intervals
  fx = f( x );                 % Get the values of the function on this sequence
  % Trapezoidal rule
  loc_result = (loc_b - loc_a) / 2.0 / (n-1) * ( fx(1) + fx(n) + 2 * sum(fx(2:n-1)) );
  fprintf (' Lab %d obtained: %f\n', labindex, loc_result );
end
% End parallel region

%% Reduction: Collect all the local results and sum them. All labs will get the same value

% Start parallel region
spmd
  tot_result = gplus( loc_results ); 
end
% End parallel region

%% Obtain the reduced value from any lab (here we choose 1)
result = tot_result{1};

fprintf ( ' Result of integration:\n' );
fprintf ( ' Estimate pi = %24.16f\n', result );
fprintf ( ' Exact value   = %24.16f\n', pi );
fprintf ( ' Error         = %e\n', abs ( result - pi ) );
fprintf ( '\n' );

return

end

%% Function to be integrated

function value = f (x)

value = 4.0 ./ ( 1.0 + x.^2);

return

end
