classdef DataSource
   %DataSource Class that creates binary data to pass to an RF tranciever
   %for basebad processing
   
   properties
      length
   end
   
   methods
      function obj = DataSource(Params) %Constructor 
         %Maybe, I should define with paramters as a superclass. Then I
         %think I can access those methods and stuff.
         
         
         obj.length = Params.nBits; %Copy number of bits into object 
         obj.SNR    = Params.SNR;   %Copy SNR struct into this object
         %Colums = singal @ snr
         %Rows   = new snr step
         %Page   = new montecarlo trial
         obj.bits = randi([0,1],obj.nbits,obj.SNR.,3])  
      end
   end
   
end

