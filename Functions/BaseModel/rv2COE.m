function [type,u,omega,theta,inc,OMEGA,a,e] = rv2COE(r,v,mu)
tolerance = 10^-10;
%Magnitudes
R = norm(r);
V = norm(v);

%Radial velocity
v_r = dot(r,v)/R;

%Angular velocity
h = cross(r,v);
H = norm(h);

%inclination
inc =  acos(h(3)/H);

%node line
K = [0,0,1];
n = cross(K,h);
N = norm(n);

%RAAN
if n(2) >= 0
    OMEGA = acos(n(1)/N);
elseif n(2) < 0
    OMEGA = 2*pi - acos(n(1)/N);
end

%Eccentricity vector
e_v = (1/mu)*(cross(v,h) - mu*r/R);
e = norm(e_v);

%Perigee argument
if e_v(3) >= 0
    omega = acos(dot(n,e_v)/(N*e));
elseif e_v(3) < 0
    omega = 2*pi - acos(dot(n,e_v)/(N*e));
end

%True anomaly
if v_r >= 0
    theta = real(acos(dot(e_v,r)/(e*R)));
elseif v_r < 0
    theta = 2*pi - real(acos(dot(e_v,r)/(e*R)));
end

%Semi-latus rectum and semimajor axis
p = H^2/mu;
a = p/(1-e^2);

%Periapse argument
u = omega + theta;

%Singularity check
if inc == 0 || inc == pi
    OMEGA = 0;
    u = atan2(r(2),r(1));
    omega = u - theta;
end
if e < tolerance
    if inc ~= 0 && inc ~= pi
        u = real(acos(dot(n,r)/(norm(n)*norm(r))));
    else
        OMEGA = 0;
        u = atan2(r(2),r(1));
    end
end


%Orbit type
type = 0;
if v_r == 0
    type  = 1;
elseif e == 1
    type = 2;
    a = inf;
elseif e>1
    type = 3;
end
end