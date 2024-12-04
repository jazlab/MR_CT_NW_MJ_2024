function [array] = filter_saccade(array,buffer)
    for i = buffer+1:length(array) - buffer
        if abs(array(i+buffer)-array(i-buffer)) > 2
            array(i-buffer:i+buffer) = NaN;
        end
    end         
end

