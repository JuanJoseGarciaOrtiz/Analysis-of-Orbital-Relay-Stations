function PlotOrbit2D(Orbit,n_points)
a = Orbit.a;
e = Orbit.e;
type = Orbit.type;
omega = Orbit.omega;
if type <=1
    rotat = [cos(omega),-sin(omega);sin(omega),cos(omega)];
    b = (1-e^2)*a;
    x = linspace(-a*(1+e),a*(1-e),n_points/2);
    y_plus = real(sqrt(1-((x+e*a)/a).^2)*b);
    y_minus = -real(sqrt(1-((x+e*a)/a).^2)*b);
    x_minus = flip(x);
    y_minus = flip(y_minus);
    % x_minus = x;
    y = [y_minus y_plus];
    x = [x_minus x];
    if ~isnan(omega)
        for i = 1:n_points
            dummy = rotat*[x(i);y(i)];
            x(i) = dummy(1);
            y(i) = dummy(2);
        end
    end
    plot(x,y)
    hold on
    axis([-a*(1+e) a*(1+e) -a*(1+e) a*(1+e)])
    plot(0,0,'o')
elseif type == 3
    rotat = [cos(omega),-sin(omega);sin(omega),cos(omega)];
    b = (1-e^2)*a;
    x = linspace(a,-a*(e-1),n_points/2);
    y_plus = sqrt(((x+e*a)/a).^2-1)*b;
    y_minus = -sqrt(((x+e*a)/a).^2-1)*b;
    x_plus = x;
    x_minus = flip(x);
    y_minus = flip(y_minus);
    if ~isnan(omega)
        for i = 1:n_points/2
            dummy = rotat*[x_minus(i);y_minus(i)];
            x_minus(i) = dummy(1);
            y_minus(i) = dummy(2);
            
            dummy = rotat*[x_plus(i);y_plus(i)];
            x_plus(i) = dummy(1);
            y_plus(i) = dummy(2);
        end
    end
    y = [y_plus y_minus];
    x = [x_plus x_minus];
    plot(x,y)
    hold on
    axis([a*e -a*e a*e -a*e])
    plot(0,0,'o')
end
end