clear;
clc;
close all;

%H = dsp.SpectrumAnalyzer
%H.SampleRate = 40e6

%% Setup
sim  = ParameterSetup(0); %Object to setup everything
TXA  = transmitter(2);    %Create object for TX
AWGN = channel;           %Create object for channel
W3 = WARP(1);             %Create object for WARP board
RXA  = receiver(TXA);     %Create object for RX

hConEnc = comm.ConvolutionalEncoder;  
hDec = comm.ViterbiDecoder('InputFormat','Hard');

%% Simulation
tic;  %Start Clock
index = 1;
for snr = sim.snr_array
    for i = 1: sim.ntrials
        uncodedBits = randi([0,1], sim.bits, 1);
        flushedBits =[uncodedBits; zeros(50,1)];
        codedBits = step(hConEnc,flushedBits);
        toSend      = broadcast(TXA,codedBits,sim);      %Do signal processing to prepare to send
        toSend = toSend  / 10000;
        %RawRecieved = transmit_over_channel(AWGN, snr, toSend, sim);
        RawRecieved = broadcast(W3,toSend);
        Demodulated = receive(RXA,RawRecieved);       
        Decoded = step(hDec, Demodulated);
        Decoded = Decoded(35:35 + length(uncodedBits)-1);
        error_count(i) = sum(abs(Decoded-uncodedBits)); %number of errors for each trials
    end
    Results.BER(index) = sum(error_count)/(sim.bits*sim.ntrials) %total errors / total bits
    str = sprintf('%0.1f %% through',100*index/sim.length);
    disp(str)
    index = index + 1; %iterate index
end
toc; 



%% Results
%Throughput = code rate * (bits/sym) * (sym/sample) * (samples/second)
Results.throughput_perfect = 1 * 1 * (1/8) * sim.Fs; %in bps
Results.throughput_actual = (1-Results.BER) * Results.throughput_perfect;
%figure()
%semilogy(sim.snr_array,Results.BER,'-o');
%grid on;
