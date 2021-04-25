function parameters = vtshape(shapeName)
%VTSHAPE Returns the vocal tract parameters for a shape
%
%
%
libName = 'VocalTractLabApi';

audioSamplingRate = 0;
numTubeSections = 0;
numVocalTractParams = 0;
numGlottisParams = 0;

[failure, audioSamplingRate, numTubeSections, numVocalTractParams, numGlottisParams] = ...
    calllib(libName, 'vtlGetConstants', audioSamplingRate, numTubeSections, numVocalTractParams, numGlottisParams);

disp(['Audio sampling rate = ' num2str(audioSamplingRate)]);
disp(['Num. of tube sections = ' num2str(numTubeSections)]);
disp(['Num. of vocal tract parameters = ' num2str(numVocalTractParams)]);
disp(['Num. of glottis parameters = ' num2str(numGlottisParams)]);

parameters = zeros(1, numVocalTractParams);

[failure, ~, parameters] = ...
  calllib(libName, 'vtlGetTractParams', shapeName, parameters);

if(failure)
    error('Could not retrieve the shape parameters!')
end

end

