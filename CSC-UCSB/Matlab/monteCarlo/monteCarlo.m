%
% Burak Himmetoglu
% bhimmetoglu@ucsb.edu
% 11-10-2016
%
% --------------------------------------------------------------------------------

function [z,s2] = monteCarlo ( nDim )
% nDim dimensional integral of exp(-x_1^2 - x_2^2 - ... - x_{nDim}^2)

vec = rand(nDim,1);            % Draw a random vector in [0,1]
vec_exp = exp(-sum(vec.^2));   % The integrand
z = vec_exp;                   % The estimated integral
s2 = vec_exp^2;                % The estimated variance

return 

end
