function [h1,h2,h3,h4,h5,h6,d1,d2,One,Two,truet1,truet2,truth_1,truth_2,truth_3,truth_4, One_noise, Two_noise, Total_noise] = generate_structure_off_noise_likelihood(min_t,scalar,off_noise, h1, h2, h3, h4, h5, h6, d1,d2)

One = zeros(1,length(h1));
Two = zeros(1,length(h1));
One_noise = zeros(1,length(h1));
Two_noise = zeros(1,length(h1));
Total_noise = zeros(1,length(h1));

truet1 = zeros(1,length(h1));
truet2 = zeros(1,length(h1));

truth_1 = zeros(1,length(h1));
truth_2 = zeros(1,length(h1));
truth_3 = zeros(1,length(h1));
truth_4 = zeros(1,length(h1));


% should sample tm from scalar dist., decision with scalar variability 
for i = 1:length(h1)
       if d1(i) == 1
            
            One(i) = max(normrnd(h4(i),scalar*(h4(i))), min_t);
            One_noise(i) = max(normrnd(h4(i),off_noise*scalar*(h4(i))), min_t);

            truet1(i) = h4(i);
       
           if d2(i) == 1
                
                Two(i) = max(normrnd(h5(i),scalar*(h5(i))), min_t);
                Two_noise(i) = max(normrnd(h5(i),off_noise*scalar*(h5(i))), min_t);
                Total_noise(i) = max(normrnd((h4(i) + h5(i)),off_noise*scalar*((h4(i) + h5(i)))),min_t);
                truet2(i) = h5(i);
                     
                truth_1(i) = 0;
                truth_2(i) = 0;
                truth_3(i) = 1;
                truth_4(i) = 0;

           elseif d2(i) == -1
    
                Two(i) = max(normrnd(h6(i),scalar*(h6(i))),min_t);
                Two_noise(i) = max(normrnd(h6(i),off_noise*scalar*(h6(i))),min_t);
                Total_noise(i) = max(normrnd((h4(i) + h6(i)),off_noise*scalar*((h4(i) + h6(i)))),min_t);
                
                truet2(i) = h6(i);
                
                truth_1(i) = 0;
                truth_2(i) = 0;
                truth_3(i) = 0;
                truth_4(i) = 1;
           end
             
       elseif d1(i) == -1
        
           One(i) = max(normrnd(h1(i),scalar*(h1(i))),min_t);
           One_noise(i) = max(normrnd(h1(i),off_noise*scalar*(h1(i))),min_t);
    
           truet1(i) = h1(i);
           
           if d2(i) == 1
       
                Two(i) = max(normrnd(h2(i),scalar*(h2(i))), min_t);
                Two_noise(i) = max(normrnd(h2(i),off_noise*scalar*(h2(i))), min_t);
                Total_noise(i) = max(normrnd((h1(i) + h2(i)),off_noise*scalar*((h1(i) + h2(i)))),min_t);
                truet2(i) = h2(i);
                
                    
                truth_1(i) = 1;
                truth_2(i) = 0;
                truth_3(i) = 0;
                truth_4(i) = 0;
               
           elseif d2(i) == -1
       
                Two(i) = max(normrnd(h3(i),scalar*(h3(i))), min_t);
                Two_noise(i) = max(normrnd(h3(i),off_noise*scalar*(h3(i))), min_t);
                Total_noise(i) = max(normrnd((h1(i) + h3(i)),off_noise*scalar*((h1(i) + h3(i)))),min_t);
    
                truet2(i) = h3(i);
               
                truth_1(i) = 0;
                truth_2(i) = 1;
                truth_3(i) = 0;
                truth_4(i) = 0;
              
           end
        end
end

end

