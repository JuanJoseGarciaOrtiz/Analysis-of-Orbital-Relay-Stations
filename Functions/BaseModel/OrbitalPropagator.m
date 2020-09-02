function [t,q] = OrbitalPropagator(tspan,q0,mu,options)
if exist('options','var')
else
options = odeset('AbsTol',1e-8,'RelTol',1e-8);
end
[t,q] = ode45(@(t,q) OrbitDynamics(t,q,mu),tspan,q0,options);
end