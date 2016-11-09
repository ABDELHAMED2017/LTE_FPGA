clear;
clc;
close all;

%% Setup 
sim  = ParameterSetup(1); %Object to setup everything
TXA  = transmitter(2);    %Create object for TX
AWGN = channel;           %Create object for channel
RXA  = receiver(TXA);     %Create object for RX

%% Simulation
snr = 10;
uncodedBits = randi([0,1], sim.bits, 1);   %Create Random Data
toSend      = broadcast(TXA,uncodedBits,sim);           %Do signal processing to prepare to send
RawRecieved = transmit_over_channel(AWGN, snr, toSend, sim);
Demodulated = receive(RXA,RawRecieved);

%% Results
%Throughput = code rate * (bits/sym) * (sym/sample) * (samples/second)
Results.throughput = 1 * 1 * (1/8) * sim.Fs; %in bps
