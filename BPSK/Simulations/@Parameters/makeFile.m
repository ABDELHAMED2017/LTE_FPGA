function makeFile(obj)

%Ask the user a bunch of questions
disp('-----Create a new Expierment Paramter File----');

disp('Generic Info')
obj.fileID = input('Filename?','s');
obj.nbits = input('  Number of bits per trial?');
obj.ntrials = input('  Number of trials?');
obj.Fs = input('  System sampling rate (Hz)?');

disp('Encoding Info')
obj.ECC.type = input('  Type? (none or CC)','s');
if obj.ECC.type ~= 'none'
   
else
   obj.ECC.rate = input('  Rate^-1? (2 for 1/2 etc)');
end


disp('RRC Info')
obj.RRC.shape = input('  Shape? (sqrt or normal)','s');
obj.RRC.rolloff = input('  Rolloff Factor? (0.2)');
obj.RRC.span = input('  Filter Span in Symbols?');
obj.RRC.factor = input('  Upsampling/Downsampling Factor?');


%Do a few calculations to get rest of important stuff
obj.ts =  1 / obj.Fs; %Sample period
obj.sampleVector = 0:(obj.bits*obj.sampsPerSymb-1); %Sample vector for plots
obj.timeVectorUp   = obj.ts*obj.sampleVector;  %Time vectors for plots
obj.timeVectorDown  = downsample(obj.timeVectorUp, obj.sampsPerSymb);
obj.snr_array = obj.snr_min:obj.snr_step:obj.snr_max;
obj.length = length(obj.snr_array);

%Save file for future runs
save(obj.fileID,obj);

end