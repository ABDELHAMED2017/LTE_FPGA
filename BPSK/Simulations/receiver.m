classdef receiver
    %RECEIVER Class that sets up a RX node.
    
    properties
        M
        H_pskDeMod
        H_RRC
    end
    
    methods
        function obj = receiver(TX) %Pass the transmitter to make a MF
            obj.M = TX.H_pskMod.ModulationOrder;
            %if (gpuDeviceCount)
            
            obj.H_pskDeMod = comm.PSKDemodulator ('ModulationOrder',obj.M,...
                'PhaseOffset',pi,...
                'BitOutput',true);
            obj.H_RRC = comm.RaisedCosineReceiveFilter(...
                'Shape',                  'Normal', ...
                'RolloffFactor',          TX.H_RRC.RolloffFactor, ...
                'FilterSpanInSymbols',    TX.H_RRC.FilterSpanInSymbols, ...
                'InputSamplesPerSymbol',  TX.H_RRC.OutputSamplesPerSymbol,...
                'DecimationFactor',       TX.H_RRC.OutputSamplesPerSymbol);
            
        end
        function output = receive(obj,input)
            filteredPadded = step(obj.H_RRC,input);        %RRC
            filteredWindowed = filteredPadded(...
                obj.H_RRC.FilterSpanInSymbols/2+1:...
                end-obj.H_RRC.FilterSpanInSymbols/2);
            outputpad = step(obj.H_pskDeMod,filteredPadded);%Demodulate
            output    = outputpad(obj.H_RRC.FilterSpanInSymbols + 1 :...
                end-obj.H_RRC.FilterSpanInSymbols);
        end
    end
end

