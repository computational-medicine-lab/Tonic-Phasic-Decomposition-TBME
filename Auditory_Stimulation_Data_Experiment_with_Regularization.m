%codeForExperiment, three step coordinate descent for deconvolution with tonic part removal
close all;
clear all;
clc;
load('ss_8_14_18.mat');
addpath('Dependencies')

sub_list1 = [11,12,14,15,18,19, 20, 21, 23, 25, 26, 7, 8, 10];
sub_list2 = [1,2,3,4,5,6,9,13,14,16,17,22,24];

malesub = [11,26,8,10,20,23,3,4,9,13,17,22,24];
femalesub = [12,15,7,18,21,25,1,2,5,6,14,16,19];

Fss = 100;
Fsy = 2;
Fsu = 4;

downsampling_factor = Fss/Fsy;

ub = [1.5 6]';
lb = [0.1 1.5]';
dirname = 'Result_04_10_2019';
mkdir(dirname);

for subject = [malesub,femalesub]

    %% 200 second to 400 second for study and downsample to have the frequency in 2 Hz
    y = downsample(ss(subject).sc(1).y,Fss/Fsy);
    y = y(200*Fsy:400*Fsy-1); y = y(:);

    minimum_peak_distance = 1; 
    parallel_operations = 8;
    tic
    
    data.y = y;
    data.ub = ub;
    data.lb = lb;
    data.Fsu = Fsu;
    data.Fsy = Fsy;
    data.minimum_peak_distance = minimum_peak_distance;
    
    parfor i=1:parallel_operations
%     [results(i).tau_j, results(i).uj, results(i).y, results(i).lambda, results(i).convergenceFlag] = coordinate_descent1(phasic_part, ub, lb, Fsu, Fsy, minimum_peak_distance);   
        fprintf('parallel loop %d\n',i);
        results(i) = CoordinateDescentWithTonicPartRemoval_with_priors(data, i)
    end
    toc
    cost_prev1 =Inf;
    cost_prev2 =Inf;
    cost_prev3 =Inf;
    cost_prev4 =Inf;
    
    for i=1:parallel_operations
        y_ = results(i).y_rec;
        lambda1 = results(i).lambda1;
        lambda2 = results(i).lambda2;
        uj = results(i).uj;
        qj = results(i).qj;
        cost1 = 0.5 * norm(y-y_,2).^2;
        cost2 = 0.5 * norm(y-y_,2).^2 + lambda1 * norm(uj, 1);
        cost3 = 0.5 * norm(y-y_,2).^2 + lambda2 * norm(qj, 2);
        cost4 = 0.5 * norm(y-y_,2).^2 + lambda1 * norm(uj, 1)+ lambda2 * norm(qj, 2);

        if(cost1<cost_prev1 && results(i).convergenceFlag == 1 && round(results(i).tauj(1)*1e4)/1e4 ~= lb(1) && round(results(i).tauj(1)*1e4)/1e4 ~= ub(1))
            result1 = results(i);
            cost_prev1 = cost1;
        end
        
        if(cost2<cost_prev2 && results(i).convergenceFlag == 1 && round(results(i).tauj(1)*1e4)/1e4 ~= lb(1) && round(results(i).tauj(1)*1e4)/1e4 ~= ub(1))
            result2 = results(i);
            cost_prev2 = cost2;
        end
        
        if(cost3<cost_prev3 && results(i).convergenceFlag == 1 && round(results(i).tauj(1)*1e4)/1e4 ~= lb(1) && round(results(i).tauj(1)*1e4)/1e4 ~= ub(1))
            result3 = results(i);
            cost_prev3 = cost3;
        end
        
        if(cost4<cost_prev4 && results(i).convergenceFlag == 1 && round(results(i).tauj(1)*1e4)/1e4 ~= lb(1) && round(results(i).tauj(1)*1e4)/1e4 ~= ub(1))
            result4 = results(i);
            cost_prev4 = cost4;
        end
    end
    save([dirname,'\result_s',num2str(subject)]);
end