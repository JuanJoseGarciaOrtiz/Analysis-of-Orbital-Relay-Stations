function [x,q] = k2x(k,r1,r2,Dtheta)
if -sqrt(2)<= k && k <= sqrt(2)
    q = (1 - sign(k))*pi + sign(k)*acos(k^2 - 1);
elseif k >= sqrt(2)
    q = -1i*acosh(k^2 -1);
end
LHS = -k*((sqrt(r1*r2)*sin(Dtheta))/((r1 + r2)*sqrt(1 - cos(Dtheta))));
x = sqrt(((LHS+1)*((r1 + r2)*q^2))/(2 - k^2));
end