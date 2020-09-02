function theta = DeltaTheta(r1,r2,ref)
%Compute the angle from r1 to r2. Values between 0 and 2pi.
theta = acos(dot(r1,r2)/(norm(r1)*norm(r2)));
if dot(cross(r1,r2),ref) < 0
    theta = 2*pi - theta;
end
end