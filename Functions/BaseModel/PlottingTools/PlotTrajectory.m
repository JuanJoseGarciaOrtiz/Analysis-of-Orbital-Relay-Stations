function PlotTrajectory(type,omega,inc,OMEGA,a,e,mu,n_points,theta1,theta2)
u = linspace(theta1,theta2,n_points);
theta = linspace(theta1,theta2,n_points);
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