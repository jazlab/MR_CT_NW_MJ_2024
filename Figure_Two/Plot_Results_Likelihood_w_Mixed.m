clear all; clc;

% adjust to your local path
addpath(genpath('/Volumes/Portable/Human_RNN/Paper_Code/Figure_Two/'));

results = load('Online_H_maze_like_all_final.mat');


H_MAZE_LIKE_ALL_J = results.H_MAZE_LIKE_ALL.J;
H_MAZE_LIKE_ALL_P = results.H_MAZE_LIKE_ALL.P;
H_MAZE_LIKE_ALL_H = results.H_MAZE_LIKE_ALL.H;
H_MAZE_LIKE_ALL_C = results.H_MAZE_LIKE_ALL.C;
H_MAZE_LIKE_ALL_M = results.H_MAZE_LIKE_ALL.M;

figure()

bar(1:5, [mean(mean(H_MAZE_LIKE_ALL_J)) mean(mean(H_MAZE_LIKE_ALL_P)) mean(mean(H_MAZE_LIKE_ALL_H)) mean(mean(H_MAZE_LIKE_ALL_M)) mean(mean(H_MAZE_LIKE_ALL_C)) ])
hold on
er = errorbar(1:5,[mean(mean(H_MAZE_LIKE_ALL_J)) mean(mean(H_MAZE_LIKE_ALL_P)) mean(mean(H_MAZE_LIKE_ALL_H)) mean(mean(H_MAZE_LIKE_ALL_M)) mean(mean(H_MAZE_LIKE_ALL_C)) ], [std(mean(H_MAZE_LIKE_ALL_J)) std(mean(H_MAZE_LIKE_ALL_P)) std(mean(H_MAZE_LIKE_ALL_H)) std(mean(H_MAZE_LIKE_ALL_M)) std(mean(H_MAZE_LIKE_ALL_C)) ]);    
er.Color = [0 0 0];                            
er.LineStyle = 'none'; 


figure()

boxplot([mean(H_MAZE_LIKE_ALL_J); mean(H_MAZE_LIKE_ALL_P); mean(H_MAZE_LIKE_ALL_H); mean(H_MAZE_LIKE_ALL_M); mean(H_MAZE_LIKE_ALL_C) ]')


figure()

violinplot([mean(H_MAZE_LIKE_ALL_J); mean(H_MAZE_LIKE_ALL_P); mean(H_MAZE_LIKE_ALL_H); mean(H_MAZE_LIKE_ALL_M); mean(H_MAZE_LIKE_ALL_C) ]', [], 'ViolinAlpha', 0.2, 'MarkerSize', 10, 'ShowMean', true)


[h,p1,ci,stats] = ttest(mean(H_MAZE_LIKE_ALL_C),mean(H_MAZE_LIKE_ALL_J),"Tail","left");
[h,p2,ci,stats] = ttest(mean(H_MAZE_LIKE_ALL_C),mean(H_MAZE_LIKE_ALL_P),"Tail","left");
[h,p3,ci,stats] = ttest(mean(H_MAZE_LIKE_ALL_C),mean(H_MAZE_LIKE_ALL_H),"Tail","left");
[h,p4,ci,stats] = ttest(mean(H_MAZE_LIKE_ALL_C),mean(H_MAZE_LIKE_ALL_M),"Tail","left");

p1 
p2
p3
p4
