%% Main file of BPSK Simulator
% From here, we will script everything. 

%% Setup
plots = 0;  %If 1, plot data. In this case, ntrials will be 1. 

bits = 1000;
sampsPerSym  = 8; %upsampling factor
beta = 0.5;       %rollof factor
Nsym = 6;         %Filter span in symbol durations

Sampling_rate = 40e6; 
time_period = Sampling_rate^-1;

H_psk_mod = comm.PSKModulator('ModulationOrder',2,...
    'PhaseOffset',pi);

H_psk_demod = comm.PSKDemodulator ('ModulationOrder',2,...
    'PhaseOffset',pi,...
    'BitOutput',true);

rctFilt = comm.RaisedCosineTransmitFilter(...
  'Shape',                  'Normal', ...
  'RolloffFactor',          beta, ...
  'FilterSpanInSymbols',    Nsym, ...
  'OutputSamplesPerSymbol', sampsPerSym);

rctFiltRX = comm.RaisedCosineReceiveFilter(...
  'Shape',                  'Normal', ...
  'RolloffFactor',          beta, ...
  'FilterSpanInSymbols',    Nsym, ...
  'InputSamplesPerSymbol', sampsPerSym);    

spectrumAnalyzer = dsp.SpectrumAnalyzer('SampleRate',Sampling_rate);

H_awgn = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (SNR)',...
    'SNR',15,...
    'BitsPerSymbol',1,...
    'SignalPower',1,...
    'SamplesPerSymbol',sampsPerSym);
    

%Check system to see if there is GPU;
%if GPU set to true
GPU = 0;

if plots == 1
    ntrials = 1  %Number of MonteCarlo Trials is set to 1 to avoid figure explosion.
end


%% Simulation

%Transmitter
dataBits = randi([0,1], bits, 1);

%Error Correction Code

%Modulate Bits
modulatedData = step(H_psk_mod,dataBits);

%padd with zeros at the end

scatter(real(modulatedData),imag(modulatedData))
grid on;
hold on;

%RRC 
filteredData = rctFilt(modulatedData);
scatter(real(filteredData),imag(filteredData));


%AWGN 
%There is a GPU version
channelData = step(H_awgn,filteredData);
scatter(real(channelData),imag(channelData));

%Receiver 

%RRC - Matched Filter
recivedSignal = step(rctFiltRX,channelData);

%Demodulate
bitsDemod = step(H_psk_demod,recivedSignal);

%OTA BER

%Channel Decoding

%Coded BER


%% Results