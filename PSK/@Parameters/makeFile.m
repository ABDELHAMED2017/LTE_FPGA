function makeFile(obj)

%Ask the user a bunch of questions
disp('-----Create a new Expierment Paramter File----');

disp('Generic Info')
obj.fileID = input('    Filename?','s');
if isempty(obj.fileID)
   obj.fileID = 'filename';
   disp(['      Using default: ' obj.fileID]);
end

obj.nbits = input('    Number of bits per trial?');
if isempty(obj.nbits)
   obj.nbits = 100;
   disp(['      Using default: ' num2str(obj.nbits)]);
end

obj.ntrials = input('    Number of trials?');
if isempty(obj.ntrials)
   obj.ntrials = 100;
   disp(['      Using default: ' num2str(obj.ntrials)]);
end

obj.Fs = input('    System sampling rate (Hz)?');
if isempty(obj.Fs)
   obj.Fs = 40e6;
   disp(['      Using default: ' num2str(obj.Fs)]);
end

disp('Encoding Info')
obj.ECC.type = input('    Type? (none or CC)','s');
if isempty(obj.ECC.type)
   obj.ECC.type = 'none';
   disp(['      Using default: ' obj.ECC.type]);
end
switch obj.ECC.type
   case 'CC'
      obj.ECC.rate = input('    Rate^-1? (2 for 1/2 etc)');
end


disp('RRC Info')
obj.RRC.shape = input('    Shape? (sqrt or normal)','s');
if isempty(obj.RRC.shape)
   obj.ECC.type = 'sqrt';
   disp(['      Using default: ' obj.ECC.type]);
end


obj.RRC.rolloff = input('    Rolloff Factor? [0, 1]');
if isempty(obj.RRC.rolloff)
   obj.RRC.rolloff  = 0.2;
   disp(['      Using default: ' num2str(obj.RRC.rolloff )]);
end


obj.RRC.span = input('    Filter Span in Symbols?');
if isempty(obj.RRC.span)
   obj.RRC.span  = 4;
   disp(['      Using default: ' num2str(obj.RRC.span)]);
end

obj.RRC.factor = input('    Upsampling/Downsampling Factor?');
if isempty(obj.RRC.factor)
   obj.RRC.factor  = 8;
   disp(['      Using default: ' num2str(obj.RRC.factor)]);
end

%Do a few calculations to get rest of important stuff
obj.ts =  1 / obj.Fs; %Sample period
obj.sampleVector = 0:(obj.nbits*obj.sampsPerSymb-1); %Sample vector for plots
obj.timeVectorUp   = obj.ts*obj.sampleVector;  %Time vectors for plots
obj.timeVectorDown  = downsample(obj.timeVectorUp, obj.sampsPerSymb);
obj.snr_array = obj.snr_min:obj.snr_step:obj.snr_max;
obj.length = length(obj.snr_array);

%Save file for future runs
cd ParameterFiles
save(char(obj.fileID));
cd ..

end