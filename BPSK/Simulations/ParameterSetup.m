classdef ParameterSetup
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        bits = 1000    %Bits per trial
        ntrials = 1000 %Montecarlo Trials
        Fs = 40*10^6   %40 MHz Sampling rate
        ts             %sample period
        plots = 1      %Plots
        sampleVector   %Vector for sample index
        timeVectorUp   %Vector for upsampled time index
        timeVectorDown %Vector for downsampled (symbol-wise) time index
        sampsPerSymb = 8 %upsampling factor of RRC filer
    end
    
    methods
        function obj = ParameterSetup(plots)
            if plots
                obj.ntrials = 1
                obj.bits = 50;
            end
            obj.ts =  1 / obj.Fs; %Sample period
            obj.sampleVector = 0:(obj.bits*obj.sampsPerSymb-1); %Sample vector for plots
            obj.timeVectorUp   = obj.ts*obj.sampleVector;  %Time vectors for plots
            obj.timeVectorDown  = downsample(obj.timeVectorUp, obj.sampsPerSymb);
        end
    end
    
end

