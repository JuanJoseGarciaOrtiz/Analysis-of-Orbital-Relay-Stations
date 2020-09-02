function [W,W_prime,W_prime2] = WauxFunction(k)
%Computes auxiliary function W, for relations of time of flight of an orbit
%   defined with global variable k. For additional information on this
%   function check Nitin ARORA and Ryan P. RUSSEL paper on multiple
%   revolution Lambert algorithm.

m = 2 - k^2;
tol = 2*10^(-2);
N = 0;

%% W value
if -sqrt(2) <= k && k<= (sqrt(2) - tol)
    %Elliptic orbits
    W = ((1-sign(k))*pi + sign(k)*acos(1-m) + 2*pi*N)/(sqrt(m^3)) - k/m;
elseif k > (sqrt(2) + tol)
    %Hyperbolic orbits
    W = (-acosh(1-m))/(sqrt(-m^3)) - k/m;
elseif (sqrt(2) - tol) <= k && k <= (sqrt(2) + tol)
    %Indeterminate case
    v = k - sqrt(2);
    W = sqrt(2)/3 - v/5 + (2/35)*sqrt(2)*v^2 - (2/63)*v^3 + (2/231)*sqrt(2)*v^4 - (2/429)*v^5 + (8/6435)*sqrt(2)*v^6 - (8/12155)*v^7 + (8/46189)*sqrt(2)*v^8;
else
    error('Unable to compute auxiliary function W, impossible to evaluate case for k')
end


%% First derivative of W with respect to k
if -sqrt(2) <= k && k<= (sqrt(2) - tol)
    W_prime = (-2 + 3*W*k)/m;
elseif k > (sqrt(2) + tol)
    W_prime = (-2 + 3*W*k)/(-m);
elseif (sqrt(2) - tol) <= k && k <= (sqrt(2) + tol)
    W_prime = -1/5 + (4/35)*sqrt(2)*v - (6/63)*v^2 + (8/231)*sqrt(2)*v^3 - (10/429)*v^4 + (48/6435)*sqrt(2)*v^5 - (56/12155)*v^6 + (64/46189)*sqrt(2)*v^7 - (72/88179)*v^8;
end

%% Second derivative of W with respect to k
if -sqrt(2) <= k && k<= (sqrt(2) - tol)
    W_prime2 = (5*W_prime*k + 3*W)/m;
elseif k > (sqrt(2) + tol)
    W_prime2 = (5*W_prime*k + 3*W)/(-m);
elseif (sqrt(2) - tol) <= k && k <= (sqrt(2) + tol)
    W_prime2 = (4/35)*sqrt(2) - (12/63)*v + (24/231)*sqrt(2)*v^2 - (40/429)^v^3 + (240/6435)*sqrt(2)*v^4 - (336/12155)*v^5 + (448/46189)*sqrt(2)*v^6 - (576/88179)*v^7;
end
end
    