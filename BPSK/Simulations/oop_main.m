clear;
clc;
close all

parameters.bits = 100;  %Bits to send per trial
TXA = transmitter(2); %Create object for TX
AWGN = channel;       %Create object for channel
RXA = receiver(TXA);
snr = 0;
parameters.Fs = 40*10^6; % 40 MHz Sampling rate
parameters.ts = 1 / parameters.Fs; %Sample period
plots = 1;
paramters.sampleVector = 0:(parameters.bits*obj.RRC.sampsPerSymb-1);  %Sample vector for plots
paramters.timeVector   = parameters.ts*sampleVector;      %Time vectors for plots
paramters.timeVectorB  = downsample(timeVector, obj.RRC.sampsPerSymb);

%% Simulation
uncodedBits = randi([0,1], parameters.bits, 1);   %Create Random Data
toSend      = broadcast(TXA,uncodedBits,plots,parameters);           %Do signal processing to prepare to send
RawRecieved = transmit_over_channel(AWGN, snr, toSend);
Demodulated = receive(RXA,RawRecieved);

%% Results
%Throughput = code rate * (bits/sym) * (sym/sample) * (samples/second)
Results.throughput = 1 * 1 * (1/8) * parameters.Fs; %in bps
