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
win = 200;
stride = 100;
for subject = [malesub(1),femalesub([])]

    %% 200 second to 400 second for study and downsample to have the frequency in 2 Hz
    
    y = downsample(ss(subject).sc(1).y,Fss/Fsy);
    ll = -stride*Fsy + 1; rr = 0;
    
    i = 0;

    data = [];
    minimum_peak_distance = 1; 
    parallel_operations = 8;
    
    while(rr < length(y))
        i = i + 1;
        ll = ll + stride * Fsy;
        rr = min(ll + win * Fsy -1, length(y));
        y_ = y(ll:rr); y_ = y_(:);
        
        data(i).ll = ll;
        data(i).rr = rr;
        data(i).y = y_;
        data(i).ub = ub;
        data(i).lb = lb;
        data(i).Fsu = Fsu;
        data(i).Fsy = Fsy;
        data(i).minimum_peak_distance = minimum_peak_distance;
    end

    tic
    
    %results = [];
    number_of_nodes = 4;
    i = 1;
    for j = 1:ceil(length(data)/number_of_nodes)
        parfor k = i:min(i+number_of_nodes,length(data))
            fprintf('segment no %d\n',k);
            data(k).result = CoordinateDescentWithTonicPartRemoval_with_priors(data(k), i);
            %data(k).result = k; % test
            %disp(k)
        end
        i = min(i+number_of_nodes,length(data))+1;
    end
    toc
    %% aggregation

        
    save([dirname,'\result_s',num2str(subject)]);
end

