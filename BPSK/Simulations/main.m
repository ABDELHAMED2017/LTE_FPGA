%% Main file of BPSK Simulator
% From here, we will script everything.
clear;   %clear workspace
clc;     %clear console
%% Setup
setup.plots   = 1;  %If 1, plot data. In this case, ntrials will be 1.
setup.ntrials = 1000;  %Montecarlo trials in simulation

TXparameters.bits          = 1000;
RRCparameters.sampsPerSym  = 8;   %Upsampling factor
RRCparameters.beta         = 0.5; %Rollof factor
RRCparameters.Nsym         = 6;   %Filter span in symbol durations

TXparameters.Fs = 40e6; %Sampling Rate
TXparameters.time_period = TXparameters.Fs^-1;

H_psk_mod = comm.PSKModulator('ModulationOrder',2,...
    'PhaseOffset',pi);

H_psk_demod = comm.PSKDemodulator ('ModulationOrder',2,...
    'PhaseOffset',pi,...
    'BitOutput',true);

rctFilt = comm.RaisedCosineTransmitFilter(...
    'Shape',                  'Normal', ...
    'RolloffFactor',          RRCparameters.beta, ...
    'FilterSpanInSymbols',    RRCparameters.Nsym, ...
    'OutputSamplesPerSymbol', RRCparameters.sampsPerSym);

rctFiltRX = comm.RaisedCosineReceiveFilter(...
    'Shape',                  'Normal', ...
    'RolloffFactor',          RRCparameters.beta, ...
    'FilterSpanInSymbols',    RRCparameters.Nsym, ...
    'InputSamplesPerSymbol',  RRCparameters.sampsPerSym);

H_awgn = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (SNR)',...
    'SNR',15,...
    'BitsPerSymbol',1,...
    'SignalPower',1,...
    'SamplesPerSymbol',RRCparameters.sampsPerSym);

if (gpuDeviceCount) %Check system to see if there is GPU;
    setup.GPU = 1;
end
if setup.plots == 1
    setup.ntrials = 1  %Number of MonteCarlo Trials is set to 1 to avoid figure explosion.
end

%% Simulation

% TRANSMITTER
TX.dataBits      = randi([0,1], TXparameters.bits , 1); %Create Random Data
                                                        %Error Correction Code
TX.modulatedData = step(H_psk_mod,TX.dataBits);         %Modulate Bits
                                                        %Padd with zeros at the end
TX.filteredData  = rctFilt(TX.modulatedData);           %RRC

% RECIEVER
RX.channelData   = step(H_awgn,TX.filteredData);       %AWGN
RX.recivedSignal = step(rctFiltRX,RX.channelData);     %RRC
RX.bitsDemod     = step(H_psk_demod,RX.recivedSignal); %Demodulate
%OTA BER
%Channel Decoding
%Coded BER

%% Results

%PLOTS from 1 trial
if setup.plots == 1
    scatter(real(modulatedData),imag(modulatedData))
    grid on;
    hold on;
    scatter(real(channelData),imag(channelData));
end