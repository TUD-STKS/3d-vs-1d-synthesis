function [t, f] = f0_contour(f0, Fs)
if size(f0, 1) < 2
    error("f0_contour: You must specify at least a start and a final f0!");
end

f = [];
t = [];
for i = 1:size(f0, 1)-1
    x = [f0(i,1), f0(i+1, 1)];
    y = [0, f0(i,2), f0(i+1, 2), 0]; % Additional zeros to ensure zero slope at endpoints
    dt = linspace(x(1), x(2), (x(2) - x(1)) * Fs);
    f = [f, spline(x,y,dt)];
    t = [t, dt];
end

end