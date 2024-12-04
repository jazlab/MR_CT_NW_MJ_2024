function [] = plot_eye_av(h1,h2,h3,h4,h5,key,d1,d2)

rectangle('Position',[-h1,0,h1,1],'EdgeColor', 'k' ,'LineWidth',3);
rectangle('Position',[0,0,h4,1],'EdgeColor', 'k' ,'LineWidth',3);
rectangle('Position',[-h1-0.5,0.5,1,h2],'EdgeColor', 'k' ,'LineWidth',3);
rectangle('Position',[-h1-0.5,-h3+0.5,1,h3],'EdgeColor', 'k' ,'LineWidth',3);
rectangle('Position',[h4-0.5,0.5,1,h5],'EdgeColor', 'k' ,'LineWidth',3);
rectangle('Position',[h4-0.5,-(10-h5)+0.5,1,(10-h5)],'EdgeColor', 'k' ,'LineWidth',3);
rectangle('Position',[-0.5,0,1,10],'EdgeColor', 'k' ,'LineWidth',3);
% rectangle('Position',[-0.5,-9,1,10],'EdgeColor', 'k' ,'LineWidth',3);


if d1== -1
    if d2 == 1
        anss = [1,2,3,4];
    elseif d2 == -1
         anss = [2,1,3,4];
    end
elseif d1 == 1
    if d2 == 1
        
        anss= [3,4,1,2];
    
    elseif d2 == -1
       anss = [4,3,2,1];  
    end
end

if key== anss(1)
        rectangle('Position',[-h1-0.75,h2-0.25,1.5,1.5],'Curvature',[1 1],'EdgeColor', 'b' ,'LineWidth',3)
elseif key== anss(2)
         rectangle('Position',[-h1-0.75,-h3-0.25,1.5,1.5],'Curvature',[1 1],'EdgeColor', 'b' ,'LineWidth',3) 
elseif key== anss(3)
        rectangle('Position',[h4-0.75,h5-0.25,1.5,1.5],'Curvature',[1 1],'EdgeColor', 'b' ,'LineWidth',3)
elseif key== anss(4)
         rectangle('Position',[h4-0.75,-(10-h5)-0.25,1.5,1.5],'Curvature',[1 1],'EdgeColor', 'b' ,'LineWidth',3)
end


axis equal
xlim([-10 10])
ylim([-10 10])

end