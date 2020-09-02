function dqdt = OrbitDynamics(t,q,mu)
r = [q(1);q(2);q(3)];
v = [q(4);q(5);q(6)];
a = -(mu/norm(r)^3)*r;

dqdt = [v(1);v(2);v(3);a(1);a(2);a(3)];
end