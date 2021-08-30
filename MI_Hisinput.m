function [MI_value] = MI_Hisinput(Phase_Data,Env_Data, reject_seg)
% -------------------------------------------------------------- %
% input: 
%     Phase_Data: phase of lower frequency component
%     Env_Data: amplitude of higher frequency component
%     reject_seg: segment index (data points) to be rejected before estimation

% output: 
%      MI_value: calculated modulation index
% -------------------------------------------------------------- %

    %%   ##    remove the bad segments marked before  ##  %%
    Phase_Data(:,reject_seg) = [];
    Env_Data(:,reject_seg) = [];


    Paired = [Phase_Data;Env_Data];
    clear Env_Data;

    num_bins = 18;
    Paired_i = cell(1,num_bins);
    j=1;

    % phase grouped into num_bins
    for pi_i = -pi:pi/9:8*pi/9
        Ind = find(Phase_Data >= pi_i & Phase_Data <= pi_i+pi/9);
        Paired_i{j} = Paired(:,Ind);
        j=j+1;
    end

    % sorted amplitude
    Ave_amplitude = zeros(num_bins,1);
    for k = 1:num_bins
        temp = Paired_i{k};
        Ave_amplitude(k) = mean(temp(2,:),2);
    end

    % normalized amplitude
    Normalized_amplitude = Ave_amplitude./sum(Ave_amplitude);

    H_P2 = -sum(Normalized_amplitude.*log(Normalized_amplitude));
    D_KL = log(num_bins)- H_P2; % deviation of P2 distribution from the uniform
                                                               
    MI_value = D_KL/log(num_bins);
     
 return;
   
