function [truth_1,truth_2,truth_3,truth_4,Total_noise] = generate_structure_NHP(h1,h2,h3,h4,min_t,scalar,which)

Total_noise = zeros(1,length(h1));

truth_1 = zeros(1,length(h1));
truth_2 = zeros(1,length(h1));
truth_3 = zeros(1,length(h1));
truth_4 = zeros(1,length(h1));


% should sample tm from scalar dist., decision with scalar variability 
for i = 1:length(h1)

    if which(i) == 1
  
            Total_noise(i) = max(normrnd( h1(i), scalar*h1(i) ) ,min_t);
            truth_1(i) = 1;
            truth_2(i) = 0;
            truth_3(i) = 0;
            truth_4(i) = 0;
            
    elseif which(i) == 2

        Total_noise(i) = max(normrnd( h2(i), scalar*h2(i) ) ,min_t);
        truth_1(i) = 0;
        truth_2(i) = 1;
        truth_3(i) = 0;
        truth_4(i) = 0;

    elseif which(i) == 3

        Total_noise(i) = max(normrnd( h3(i), scalar*h3(i) ) ,min_t);
            truth_1(i) = 0;
            truth_2(i) = 0;
            truth_3(i) = 1;
            truth_4(i) = 0;

     elseif which(i) == 4

        Total_noise(i) = max(normrnd( h4(i), scalar*h4(i) ) ,min_t);
            truth_1(i) = 0;
            truth_2(i) = 0;
            truth_3(i) = 0;
            truth_4(i) = 1;

    end

end


end

