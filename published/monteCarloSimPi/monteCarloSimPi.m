clc;
clear all;
format long;

delete(gcp)
parpool(1)
% global var
N = 1e6; %  number of tests

jj = 0;
kk = 0;

for ii = 1:N
    % define random x- y- coordinates
    x(ii,1) = rand;
    y(ii,1) = rand;
    r = sqrt( x(ii,1)^2 + y(ii,1)^2);
    
    if r <= 1
        jj = jj + 1;
        inX(jj) = x(ii,1);
        inY(jj) = y(ii,1);
    else 
        kk = kk + 1;
        outX(kk) = x(ii,1);
        outY(kk) = y(ii,1);
    end
end
%plot(inX,inY,'r.',outX,outY,'b.')
(( 4*length(inX)/N) + (4*length(inY)/N) )/2