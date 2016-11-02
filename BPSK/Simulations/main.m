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

TX.H_psk_mod = comm.PSKModulator('ModulationOrder',2,...
    'PhaseOffset',pi);

RX.H_psk_demod = comm.PSKDemodulator ('ModulationOrder',2,...
    'PhaseOffset',pi,...
    'BitOutput',true);

TX.rctFilt = comm.RaisedCosineTransmitFilter(...
    'Shape',                  'Normal', ...
    'RolloffFactor',          TX.RRC.beta, ...
    'FilterSpanInSymbols',    TX.RRC.Nsym, ...
    'OutputSamplesPerSymbol', TX.RRC.sampsPerSym);
% Normalize to obtain maximum filter tap value of 1
TX.RRC.b     = coeffs(TX.rctFilt);
TX.rctFilt.Gain = 1/max(TX.RRC.b.Numerator);

RX.rctFilt = comm.RaisedCosineReceiveFilter(...
    'Shape',                  'Normal', ...
    'RolloffFactor',          TX.RRC.beta, ...
    'FilterSpanInSymbols',    TX.RRC.Nsym, ...
    'InputSamplesPerSymbol',  TX.RRC.sampsPerSym);

RX.H_awgn = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (SNR)',...
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
TX.data.modulated   = step(TX.H_psk_mod,TX.data.uncodedBits);  %Modulate Bits
%Padd with zeros at the end
TX.data.filtered    = step(TX.rctFilt,TX.data.modulated);      %RRC
RX.H_awgn.SignalPower  = real(mean(TX.data.filtered.^2));      %Update signal power

% RECIEVER
RX.data.channel     = step(RX.H_awgn,TX.data.filtered); %AWGN
RX.z = RX.data.channel - TX.data.filtered; %Calculate the noise
RX.snr = snr(TX.data.filtered , RX.z);        %Sanity check on snr
RX.data.RRCFiltered = step(RX.rctFilt,RX.data.channel);      %RRC
RX.data.demod       = step(RX.H_psk_demod,RX.data.RRCFiltered);%Demodulate
%OTA BER
%Channel Decoding
%Coded BER

%% Results

%PLOTS from 1 trial
if setup.plots == 1
    figure(1)
    scatter(real(RX.data.channel) ,imag(RX.data.channel));
    axis([-2 2 -1 1]);grid on; hold on;
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
    stem(TX.data.timeVectorB,real(TX.data.modulated));
    figure(3)
    [pxx,f] = pwelch(TX.data.filtered,[],[],[],TX.parameters.Fs,'centered','power');
    plot(f,10*log10(pxx));
    xlabel('Frequency (Hz)')
    ylabel('Magnitude (dB)')
    grid on;
    hold on;
    [pxx,f] = pwelch(RX.data.channel,[],[],[],TX.parameters.Fs,'centered','power');
    plot(f,10*log10(pxx));
    legend('TX data', 'RX data');
end