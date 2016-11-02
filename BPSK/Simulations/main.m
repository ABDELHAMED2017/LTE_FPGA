%% Main file of BPSK Simulator
% From here, we will script everything.
clear;     %clear workspace
clc;       %clear console
close all; %close all figures
%% Setup
setup.plots   = 1;  %If 1, plot data. In this case, ntrials will be 1.
setup.ntrials = 10;  %Montecarlo trials in simulation

TX.parameters.bits = 50;   %Bits per trial
TX.parameters.SNR  = 20;   %SNR to try
TX.RRC.sampsPerSym = 8;    %Upsampling factor
TX.RRC.beta        = 0.5;  %Rollof factor
TX.RRC.Nsym        = 6;    %Filter span in symbol durations
TX.parameters.Fs   = 40e6; %Sampling Rate (Hz)
TX.parameters.ts   = TX.parameters.Fs^-1; %Time period (s)

H_psk_mod = comm.PSKModulator('ModulationOrder',2,...
    'PhaseOffset',pi);

H_psk_demod = comm.PSKDemodulator ('ModulationOrder',2,...
    'PhaseOffset',pi,...
    'BitOutput',true);

rctFilt = comm.RaisedCosineTransmitFilter(...
    'Shape',                  'Normal', ...
    'RolloffFactor',          TX.RRC.beta, ...
    'FilterSpanInSymbols',    TX.RRC.Nsym, ...
    'OutputSamplesPerSymbol', TX.RRC.sampsPerSym);
% Normalize to obtain maximum filter tap value of 1
TX.RRC.b     = coeffs(rctFilt);
rctFilt.Gain = 1/max(TX.RRC.b.Numerator);

rctFiltRX = comm.RaisedCosineReceiveFilter(...
    'Shape',                  'Normal', ...
    'RolloffFactor',          TX.RRC.beta, ...
    'FilterSpanInSymbols',    TX.RRC.Nsym, ...
    'InputSamplesPerSymbol',  TX.RRC.sampsPerSym);

H_awgn = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (SNR)',...
    'SNR',TX.parameters.SNR,...
    'SignalPower',1);

if (gpuDeviceCount) %Check system to see if there is GPU;
    setup.GPU = 1;
end
if setup.plots == 1
    setup.ntrials = 1; %Number of MonteCarlo Trials is set to 1 to avoid figure explosion.
end

TX.data.sampleVector = 0:(TX.parameters.bits*TX.RRC.sampsPerSym-1);  %Sample vector for plots
TX.data.timeVector   = TX.parameters.ts*TX.data.sampleVector;      %Time vectors for plots
TX.data.timeVectorB  = downsample(TX.data.timeVector, TX.RRC.sampsPerSym);
%% Simulation

% TRANSMITTER
TX.data.uncodedBits = randi([0,1], TX.parameters.bits , 1); %Create Random Data
TX.data.codedBits   = TX.data.uncodedBits;                  %Error Correction Code
TX.data.modulated   = step(H_psk_mod,TX.data.uncodedBits);  %Modulate Bits
%Padd with zeros at the end
TX.data.filtered    = step(rctFilt,TX.data.modulated);      %RRC

% RECIEVER
RX.data.channel     = step(H_awgn,TX.data.filtered);        %AWGN
RX.data.RRCFiltered = step(rctFiltRX,RX.data.channel);      %RRC
RX.data.demod       = step(H_psk_demod,RX.data.RRCFiltered);%Demodulate
%OTA BER
%Channel Decoding
%Coded BER

%% Results

%PLOTS from 1 trial
if setup.plots == 1
    figure(1)
    scatter(real(RX.data.channel) ,imag(RX.data.channel));
    axis([-1 1 -1 1]);grid on; hold on;
    scatter(real(TX.data.filtered ),imag(TX.data.filtered ));
    scatter(real(TX.data.modulated),imag(TX.data.modulated),'x','LineWidth',3);
    legend('Recieved Data','TX after pulseshaping','Modulated TX symbols');
    str = sprintf('SNR of %d, Constellation Plot',TX.parameters.SNR );
    title(str);
    figure(2)
    plot(TX.data.timeVector,real(TX.data.filtered));
    xlabel('time (s)')
    ylabel('Amplitude')
    grid on;
    hold on;
    stem(TX.data.timeVectorB,(TX.data.modulated));
end