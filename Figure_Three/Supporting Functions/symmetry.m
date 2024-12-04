function [output1] = symmetry(arg1)
% Symmetry configurations

if arg1 == 3 || arg1 == 7
    output1 = 1;
elseif arg1 == 4 || arg1 == 6
    output1 = 2;
elseif arg1 == 5
    output1 = 3;
else
    output1 = 0;
end
end

