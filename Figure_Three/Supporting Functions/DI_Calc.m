function [di] = DI_Calc(left,right)

if (left == 3 & right == 1) || (left == 1 & right == 3)
    di = 4;
elseif (left == 3 & right == 2) || (left == 2 & right == 3)
    di = 3;
elseif (left == 1 & right == 2) || (left == 2 & right == 1) 
    di = 2;
else
    di = 1;
end

end

