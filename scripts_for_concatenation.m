clear all;
close all;
clc;

result_dir = 'Hamids_Dataset\results1';
win = 200;
stride = 100;
result = [];



% sub1 = [1, 2, 3, 4, 6, 8];
% sub2 = [1, 2, 3, 4, 5, 6, 7, 8, 12, 15, 16];
% sub3 = [2, 3, 4, 5, 6, 7];


% additional subjects
sub1 = [7,9,10,11,13,14];
sub2 = [10,13];
sub3 = [1,9,10,14];


% additional subjects 2
sub1 = [19,26,27];
sub2 = [];
sub3 = [17,18,20,21,22,23,24,25];



for exp = 1:3
    
    if exp == 1
        sub_list = sub1;
    elseif exp == 2
        sub_list = sub2;
    elseif exp == 3
        sub_list = sub3;
    end
    
    result_dir = ['Hamids_Dataset/results',num2str(exp)];

    for sub = sub_list
        close all;
       load([result_dir,'\result_s',num2str(sub),'.mat'],'data');
       stridey = stride * data(1).Fsy;
       strideu = stride * data(1).Fsu;
       N = length(data);
       result.y = [];
       result.u = [];
       for i = 1:N
           if(i == 1)
               result.y = [result.y; data(i).y(1:end-round(stridey/2))];
               result.y_rec = [result.y; data(i).result.y_rec(1:end-round(stridey/2))];
               result.y_tonic = [result.y; data(i).result.y_tonic(1:end-round(stridey/2))];
               result.y_phasic = [result.y; data(i).result.y_phasic(1:end-round(stridey/2))];

               result.u = [result.u; data(i).result.uj(1:end-round(strideu/2))];
           elseif(i == N)
               result.y = [result.y; data(i).y(round(stridey/2)+1:end)];
               result.y_rec = [result.y; data(i).result.y_rec(round(stridey/2)+1:end)];
               result.y_tonic = [result.y; data(i).result.y_tonic(round(stridey/2)+1:end)];
               result.y_phasic = [result.y; data(i).result.y_phasic(round(stridey/2)+1:end)];


               result.u = [result.u; data(i).result.uj(round(strideu/2)+1:end)];
           else
               result.y = [result.y; data(i).y(round(stridey/2)+1:end-round(stridey/2))];
               result.y_rec = [result.y; data(i).result.y_rec(round(stridey/2)+1:end-round(stridey/2))];
               result.y_tonic = [result.y; data(i).result.y_tonic(round(stridey/2)+1:end-round(stridey/2))];
               result.y_phasic = [result.y; data(i).result.y_phasic(round(stridey/2)+1:end-round(stridey/2))];

               result.u = [result.u; data(i).result.uj(round(strideu/2)+1:end-round(strideu/2))];
           end
       end
       ty = (0:length(result.y)-1) / data(1).Fsy;
       tu = (0:length(result.u)-1) / data(1).Fsu;
       plot(ty, result.y); hold on;
       plot(tu, result.u)
       result.ty = ty;
       result.tu = tu;
       save([result_dir,'\result_s',num2str(sub)],'data','result');
    end

end