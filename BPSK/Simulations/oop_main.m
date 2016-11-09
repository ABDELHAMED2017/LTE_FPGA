clear;
clc;
close all;

%% Setup
sim  = ParameterSetup(0); %Object to setup everything
TXA  = transmitter(2);    %Create object for TX
AWGN = channel;           %Create object for channel
RXA  = receiver(TXA);     %Create object for RX

%% Simulation
tic;  %Start Clock
j = 1;
for snr = sim.snr_array
    parfor i = 1: sim.ntrials
        uncodedBits = randi([0,1], sim.bits, 1);   %Create Random Data
        toSend      = broadcast(TXA,uncodedBits,sim);      %Do signal processing to prepare to send
        RawRecieved = transmit_over_channel(AWGN, snr, toSend, sim);
        Demodulated = receive(RXA,RawRecieved);
        error_count(i) = sum(abs(Demodulated-uncodedBits)); %number of errors for each trials
    end
    Results.BER(j) = sum(error_count)/(sim.bits*sim.ntrials); %total errors / total bits
    str = sprintf('%0.1f %% through',100*j/sim.length);
    disp(str)
    j = j + 1; %iterate index
end
toc; 

%% Results
%Throughput = code rate * (bits/sym) * (sym/sample) * (samples/second)
Results.throughput_perfect = 1 * 1 * (1/8) * sim.Fs; %in bps

semilogy(sim.snr_array,Results.BER);
grid on
