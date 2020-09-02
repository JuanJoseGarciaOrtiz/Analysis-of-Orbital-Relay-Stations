function [r,v] = COE2rv(type,omega,theta,inc,OMEGA,a,e,u,mu)
%Gives r and v vector in intertial frame of reference given the classical
%orbital parameters

if type ~= 1
    u = omega + theta; %Check if true argument of latitude is defined
    rho = a*(1-e^2)/(1+e*cos(theta)); %Radial distance
else
    rho = a; %For circular orbits
end


p = a*(1-e^2); %Semi-latus rectum
h = sqrt(mu*p); %Angular momentum
v_total = sqrt(mu*(2/rho-1/a)); %Velocity magnitude, vis-viva equation
v_t = h/rho; %Tangential velocity
if sin(theta) > 0
    v_r = sqrt(v_total^2-v_t^2); %Radial velocity
else
    v_r = -sqrt(v_total^2-v_t^2); %Radial velocity
end

if type == 1
    v_r = 0; %Circular orbits have no radial velocity
end

%Position and velocity in local frame
r_COE = [rho;0;0];
v_COE = [v_r;v_t;0];

%Rotation matrices
M_OMEGA = [cos(OMEGA),-sin(OMEGA),0;sin(OMEGA),cos(OMEGA),0;0,0,1];
M_i = [1,0,0;0,cos(inc),-sin(inc);0,sin(inc),cos(inc)];
M_u = [cos(u),-sin(u),0;sin(u),cos(u),0;0,0,1];

r = M_OMEGA*M_i*M_u*r_COE;
v = M_OMEGA*M_i*M_u*v_COE;
end