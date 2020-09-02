function PlotOrbit3D(type,omega,inc,OMEGA,a,e,mu,n_points)
u = linspace(0,2*pi,n_points);
theta = linspace(0,2*pi,n_points);
r = zeros(3,n_points);
v = zeros(3,n_points);
for i = 1:n_points
    [r(:,i),v(:,i)] = COE2rv(type,omega,theta(i),inc,OMEGA,a,e,u(i),mu);
end

plot3(r(1,:),r(2,:),r(3,:))
xlabel('x')
ylabel('y')
zlabel('z')
grid on