function ref = ChooseShortArc(r_1,r_2,ref)
Dtheta = DeltaTheta(r_1,r_2,ref);
if 0 <= Dtheta && Dtheta <= pi
    ref = ref;
elseif pi < Dtheta && Dtheta <= 2*pi
    ref = -ref;
end
end