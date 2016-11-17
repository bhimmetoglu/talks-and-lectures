%
% Burak Himmetoglu
% bhimmetoglu@ucsb.edu
% 11-10-2016
%
% Exact value of the integral
% --------------------------------------------------------------------------------

function value = exact( nDim, x )
% Exact value of the integral

value = ((normcdf(x*sqrt(2.)) - 0.5)*sqrt(pi)).^nDim;

return

end

