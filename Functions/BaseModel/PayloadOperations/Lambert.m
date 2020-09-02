function [v1,v2] = Lambert(r_1,r_2,Dt,ref,mu)
% Solves Lambert problem between points r_1 and r_2 in the perifocal
%       reference frame of body with gravitational parameter mu in a time
%       of flight Dt using algorithm by Nitin Arora and Ryan P. Russell.
%
%       Outputs are velocity vectors on points r_1 and r_2 of the
%       resulting conical section orbit.

%       Input parameters must be dimensioanlly consistent. The algorithm
%       lacks a clever intial guess strategy to optimise for fast
%       convergence

%% Preliminary geometry parameters
r1 = norm(r_1);
r2 = norm(r_2);
Dtheta = DeltaTheta(r_1,r_2,ref);
if 0 <= Dtheta && Dtheta <= pi
    d = 1;
elseif pi < Dtheta && Dtheta <= 2*pi
    d = -1;
end
tau = d*(sqrt(r1*r2*(1 + cos(Dtheta)))/(r1 + r2));
S = sqrt((r1 + r2)^3/mu);

%% Iteration using Halleys method
tol = 1;
k = -sqrt(2)/2; %Initial guess
[TOF,TOF_prime,TOF_prime2] = TimeOfFlight(k,tau,S);
L = TOF - Dt;
n_iterations = 1;
while abs(L) > tol
    Deltak = -L*(TOF_prime - (L*TOF_prime2)/(2*TOF_prime))^(-1);
    k = k + Deltak;
    [TOF,TOF_prime,TOF_prime2] = TimeOfFlight(k,tau,S);
    L = TOF - Dt;
    n_iterations = n_iterations + 1;
end

%% Lagrange multipliers
[x,q] = k2x(k,r1,r2,Dtheta);
p = (r1*r2*q^2*(1 - cos(Dtheta)))/(x^2*(2 - k^2));

f = 1 - (r2/p)*(1 - cos(Dtheta));
g = (r1*r2*sin(Dtheta))/sqrt(mu*p);
g_dot = 1 - (r1/p)*(1 - cos(Dtheta));

v1 = (r_2 - f*r_1)/g;
v2 = (g_dot*r_2 - r_1)/g;
end