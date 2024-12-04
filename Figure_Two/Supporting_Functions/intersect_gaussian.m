function [x1] = intersect_gaussian(mu1,sigma1,mu2,sigma2)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

a = 1/(2* (sigma1^2)) - 1/(2*(sigma2^2));
b = mu2/(sigma2^2) - mu1/(sigma1^2);
c = mu1^2/(2*(sigma1^2)) - mu2^2/(2*(sigma2^2)) - log(sigma2/sigma1);
% D = b^2 - 4 * a * c;
% x1 = (-b + sqrt(D))/(2*a);
root_vals = roots([a,b,c]);
[val,i] = min(abs(root_vals' - (mu1 + mu2)/2));
x1 = root_vals(i);



  
end

