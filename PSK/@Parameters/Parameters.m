classdef Parameters < handle
   %Parameters Set up all expierment parameters.
   
   properties
      nbits    %Bits per trialS
      ntrials  %Montecarlo Trials
      Fs       %Sampling rate
      ts       %sample period
      plots    %Plots
      sampleVector   %Vector for sample index
      timeVectorUp   %Vector for upsampled time index
      timeVectorDown %Vector for downsampled (symbol-wise) time index
      SNR
      RRC
      ECC
      fileID
   end
   
   methods
      function obj = Parameters(plots,fileID)  %Input a parameter file
         
         switch nargin
            case 1
               fileID = 0;
            case 0
               plots = 0;
               fileID = 0;
         end
         
         %Save to object
         obj.fileID = fileID;
         obj.plots = plots;
         
         if fileID == 0 %No paramter file input
            makeFile(obj) %Create a paramter file.
         else
            %Load file into properties
            cd ParameterFiles\
            load(obj.fileID)
            cd ..
         end
         
         if plots
            obj.ntrials = 1;  %Only need 1 trial to avoid TONS of plots
            obj.nbits = 50;   %Few number of bits for easier figs
            obj.SNR.min = 0;  %One SNR step
            obj.SNR.max = 0;
         end
      end
   end
end

