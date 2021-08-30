function [MI_Fres_Flip] =  PAC_main(x_Data, y_Data, srate,reject_seg)
%--------------------------------------------------------------------------

% input: 
%       x_Data: time series for phase extraction
%       y_Data: time series for amplitude extraction
%       Note: if PAC is calculated within one signal, x_Data should be the same with y_Data.
%       srate: sampling frequency
%       reject_seg: data points to be excluded for calculation of PAC       
% Output:
%        MI_Fres_Flip: a matrix of PAC comodulogram: [amp. * pha.] 
         
%--------------------------------------------------------------------------


% % ###### frequency range of interest ###### % %
Low_Filt_num =  4:2:50;
High_Filt_num = 4:4:170;

len_amp = size(High_Filt_num,2);
len_pha = size(Low_Filt_num,2) - 1;


%%     MI matrix definition      %%
MI_Fres = zeros(len_pha,len_amp);

for ii =  1:len_pha    
     
    band_wid = (Low_Filt_num(ii) + Low_Filt_num(ii+1))/4; % for: fa-fc,fa+fc: divided by 2
    idx_lowest = Low_Filt_num(ii+1) + band_wid;
    
    idx_high = find(High_Filt_num > idx_lowest);  
    [Low_Data,~] = eegfilt(x_Data,srate,Low_Filt_num(ii),Low_Filt_num(ii+1),0,[],0,'fir1',0);
     
     
     % calculate the angle value of **lower** filtered data      
     Phase_Data = angle(hilbert(Low_Data)); % in radians

     % remove the segments marked before 
     Phase_Data(:,reject_seg) = [];

    if idx_high
        for jj =  idx_high(1) : len_amp

         
            [High_Data,~] = eegfilt(y_Data,srate,High_Filt_num(jj)-band_wid,High_Filt_num(jj)+band_wid,0,[],0,'fir1',0);   

            % calculate the amplitude of **higher** filtered data
            Env_Data = abs(hilbert(High_Data));

            % remove the bad segments marked before  %       
            Env_Data(:,reject_seg) = [];  

            % %   call the function to calculate MI     %%

            MI_Fres(ii, jj) = MI_Hisinput(Phase_Data, Env_Data, []); % if the rejection is already performed, here the parameter for exclusion should be empty.  
                 
        end
    end
end

MI_Fres_Flip = MI_Fres';
return;
