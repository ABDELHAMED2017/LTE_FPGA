classdef DataSource
   %DataSource Class that creates binary data to pass to an RF tranciever
   %for basebad processing
   
   properties
      bitsVector
   end
   
   methods
      function obj = DataSource(Params) %Constructor 
         
         %Colums = singal @ snr
         %Rows   = new snr step
         %Page = new montecarlo trial
         obj.bitsVector = randi([0,1], ...
            [Params.nbits,Params.SNR.arrayLength,Params.ntrials]) ;
      end
   end
   
end

