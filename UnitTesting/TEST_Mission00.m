function tests = TEST_Mission00
tests = functiontests(localfunctions);
end

%% Test that the input reading is correct
function test_Mission00input(testCase)
    InputData = ReadMission00Data('TestInputMission00.txt');
    ExpectedInput.PayloadMass = 10;
    ExpectedInput.InitialStation = 3;
    ExpectedInput.FinalStation = 5;
    ExpectedInput.WaitingTime = [1000,2000];
    ExpectedInput.TimeOfFlight = [3500,4500];
    verifyEqual(testCase,InputData,ExpectedInput)
end


%% Test orbit propagator
function test_Mission00_Propagator1(testCase)
    %Test case arbitrary elliptic orbit
    mu = 3.986*10^5; %km^3/s^2
    mass = 10;
    type = 0;
    a = 42164; %km
    e = 0.1;
    omega = 0;
    theta = 0;
    inc = 0;
    RAAN = 0;
    
    %Define initial r and v and tspan for integration
    T = 2*pi*sqrt(a^3/mu);
    t_values = floor(T);
    tspan = linspace(0,T,t_values); %Half period tspan
    [r_init,v_init] = COE2rv(type,omega,theta,inc,RAAN,a,e,0,mu);
    
    x = r_init(1);
    y = r_init(2);
    z = r_init(3);
    x_dot = v_init(1);
    y_dot = v_init(2);
    z_dot = v_init(3);
    q0 = [x;y;z;x_dot;y_dot;z_dot];
    
    %Integrate
    [~,q] = OrbitalPropagator(tspan,q0,mu);
    %Assign new COE values
    r = [q(:,1),q(:,2),q(:,3)];
    v = [q(:,4),q(:,5),q(:,6)];
    [type_f,u_f,omega_f,theta_f,inc_f,OMEGA_f,a_f,e_f] = rv2COE(r(t_values,:),v(t_values,:),mu);
    
    verifyEqual(testCase,type_f,type);
    verifyEqual(testCase,min(abs(omega_f-omega),abs(omega_f-omega)-2*pi),0,'AbsTol',10^-6);
    verifyEqual(testCase,min(abs(theta_f-theta),abs(theta_f-theta)-2*pi),0,'AbsTol',10^-6);
    verifyEqual(testCase,inc_f,inc,'AbsTol',10^-6);
    verifyEqual(testCase,OMEGA_f,RAAN,'AbsTol',10^-6);
    verifyEqual(testCase,a_f,a,'RelTol',10^-6);
    verifyEqual(testCase,e_f,e,'RelTol',10^-6);
end

function test_Mission00_Propagator2(testCase)
    %Test case arbitrary elliptic orbit
    mu = 3.986*10^5; %km^3/s^2
    mass = 10;
    type = 0;
    a = 42164; %km
    e = 0.05;
    omega = pi/4;
    theta = pi/6;
    inc = pi/10;
    RAAN = pi/20;
    
    %Define initial r and v and tspan for integration
    T = 2*pi*sqrt(a^3/mu);
    t_values = floor(T);
    tspan = linspace(0,T,t_values); %Half period tspan
    [r_init,v_init] = COE2rv(type,omega,theta,inc,RAAN,a,e,0,mu);
    
    x = r_init(1);
    y = r_init(2);
    z = r_init(3);
    x_dot = v_init(1);
    y_dot = v_init(2);
    z_dot = v_init(3);
    q0 = [x;y;z;x_dot;y_dot;z_dot];
    
    %Integrate
    [~,q] = OrbitalPropagator(tspan,q0,mu);
    %Assign new COE values
    r = [q(:,1),q(:,2),q(:,3)];
    v = [q(:,4),q(:,5),q(:,6)];
    [type_f,u_f,omega_f,theta_f,inc_f,OMEGA_f,a_f,e_f] = rv2COE(r(t_values,:),v(t_values,:),mu);
    
    verifyEqual(testCase,type_f,type);
    verifyEqual(testCase,min(abs(omega_f-omega),abs(abs(omega_f-omega)-2*pi)),0,'AbsTol',10^-6);
    verifyEqual(testCase,min(abs(theta_f-theta),abs(abs(theta_f)-theta-2*pi)),0,'AbsTol',10^-6);
    verifyEqual(testCase,inc_f,inc,'AbsTol',10^-6);
    verifyEqual(testCase,OMEGA_f,RAAN,'AbsTol',10^-6);
    verifyEqual(testCase,a_f,a,'RelTol',10^-6);
    verifyEqual(testCase,e_f,e,'RelTol',10^-6);
end
%% Test Lambert algorithm
function test_LambertFunction1(testCase)
    %Test case arbitrary elliptic orbit
    mu = 3.986*10^5; %km^3/s^2
    mass = 10;
    type = 0;
    a = 42164; %km
    e = 0.1;
    omega = 0;
    inc = 0;
    OMEGA = 0;
    u = NaN;
    
    
    theta1 = 0;
    theta2 = pi/4;
    
    E1 = acos((e + cos(theta1))/(1 + e*cos(theta1)));
    E2 = acos((e + cos(theta2))/(1 + e*cos(theta2)));
    n_e = sqrt(mu/a^3);
    Deltat = (E2 - E1 - e*sin(E2) + e*sin(E1))/n_e;
    
    [r_1,v_1] = COE2rv(type,omega,theta1,inc,OMEGA,a,e,u,mu);
    [r_2,v_2] = COE2rv(type,omega,theta2,inc,OMEGA,a,e,u,mu);
    
    [v1_Lambert,v2_Lambert] = Lambert(r_1,r_2,Deltat,cross(r_1,v_1),mu);
    verifyEqual(testCase,v1_Lambert(1),v_1(1),'AbsTol',10^-4);
    verifyEqual(testCase,v1_Lambert(2),v_1(2),'RelTol',10^-4);
    verifyEqual(testCase,v1_Lambert(3),v_1(3),'AbsTol',10^-4);
    verifyEqual(testCase,v2_Lambert(1),v_2(1),'RelTol',10^-4);
    verifyEqual(testCase,v2_Lambert(2),v_2(2),'RelTol',10^-4);
    verifyEqual(testCase,v2_Lambert(3),v_2(3),'AbsTol',10^-4);
end

function test_LambertFunction2(testCase)
    mu = 3.986*10^5; %km^3/s^2
    mass = 10;
    type = 0;
    a = 42164; %km
    e = 0.05;
    omega = pi/4;
    inc = pi/10;
    OMEGA = pi/20;
    u = NaN;
    
    
    theta1 = 0;
    theta2 = pi/4;
    
    E1 = acos((e + cos(theta1))/(1 + e*cos(theta1)));
    E2 = acos((e + cos(theta2))/(1 + e*cos(theta2)));
    n_e = sqrt(mu/a^3);
    Deltat = (E2 - E1 - e*sin(E2) + e*sin(E1))/n_e;
    
    [r_1,v_1] = COE2rv(type,omega,theta1,inc,OMEGA,a,e,u,mu);
    [r_2,v_2] = COE2rv(type,omega,theta2,inc,OMEGA,a,e,u,mu);
    
    v_1 = real(v_1);
    v_2 = real(v_2);
    
    [v1_Lambert,v2_Lambert] = Lambert(r_1,r_2,Deltat,cross(r_1,v_1),mu);
    verifyEqual(testCase,v1_Lambert(1),v_1(1),'RelTol',10^-4);
    verifyEqual(testCase,v1_Lambert(2),v_1(2),'RelTol',10^-4);
    verifyEqual(testCase,v1_Lambert(3),v_1(3),'AbsTol',10^-4);
    verifyEqual(testCase,v2_Lambert(1),v_2(1),'RelTol',10^-4);
    verifyEqual(testCase,v2_Lambert(2),v_2(2),'AbsTol',10^-4);
    verifyEqual(testCase,v2_Lambert(3),v_2(3),'AbsTol',10^-4);
end