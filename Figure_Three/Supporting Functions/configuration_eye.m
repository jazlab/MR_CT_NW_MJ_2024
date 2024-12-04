function [results_xf,results_yf,results_xs,results_ys,order_trial] = configuration_eye(f1,f2,f3,xf,yf,xs,ys)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

results_xf = cell(5,5,3);
results_yf = cell(5,5,3);
results_xs = cell(5,5,3);
results_ys = cell(5,5,3);
order_trial = cell(5,5,3);

indices = 3:7;
sym = 1:3;
for l = 1:length(f1)
    for y1 = 1:length(indices)
        for y2 =  1:length(indices)
            for y3 = 1:length(sym)
                if f1(l) == indices(y1)& f2(l) == indices(y2) & symmetry(f3(l)) == y3 & symmetry(f3(l)) ~= 0 
                                results_xf{y1,y2,y3} = vertcat(results_xf{y1,y2,y3}, xf(l));
                                results_yf{y1,y2,y3} = vertcat(results_yf{y1,y2,y3}, yf(l));
                                results_xs{y1,y2,y3} = vertcat(results_xs{y1,y2,y3}, xs(l));
                                results_ys{y1,y2,y3} = vertcat(results_ys{y1,y2,y3}, ys(l));
                                order_trial{y1,y2,y3} = vertcat(order_trial{y1,y2,y3}, l);
                               
                                                             
                        end
                    end
                end           
            end
         end
                      
end


