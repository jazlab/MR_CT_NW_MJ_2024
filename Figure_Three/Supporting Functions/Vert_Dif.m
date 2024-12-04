function [output1] = Vert_Dif(arg1,arg2)
% Symmetry configurations

if abs(arg1 - arg2) == 4
    output1 = 1;
elseif abs(arg1 - arg2) == 2
    output1 = 2;
elseif abs(arg1 - arg2) == 0
    output1 = 3;
else
    output1 = 0;
end
end

