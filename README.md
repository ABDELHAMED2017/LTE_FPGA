# LTE FPGA
Ongoing project to develop an FPGA implementation of the LTE Protocols. This is intended to be developed for the WARPv3 SDR board (warpproject.org/). It serves the purpose of being a learning expierence in the following ways:

* Learn basic DSP concepts 
* Learn basic communication systems concepts
* Improve hardware design skills using verilog/system generator

With the final version of this project, we will be able to run expierements using the design for other research purposes.

## Roadmap
The project will be lengthy and inderect. Before we can implement the LTE PHY in the FPGA, we will practice on easier problems such as BPSK. 

1. End-to-end simulation of a BPSK system in MATLAB
2. WARPLab Tests. 
2. Implementation of the BPSK in FPGA
3. Extension to arbitrary M-PSK
2. WARPLab Tests. 
4. Simulation of LTE downlink PHY in MATLAB
2. WARPLab Tests. 
5. Implementation of LTE uplink PHY
6. Implementation of MAC Layer using microblaze
7. Extensions such as MIMO

## 1. MATLAB details
We want to be able to do end to end simulations of BPSK communications systems to be able to calculate BER vs SNR and EbN0 curves. We also want to be able to analyze details such as throughput, channel coding, and bit/s/Hz.
