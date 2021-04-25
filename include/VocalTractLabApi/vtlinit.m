function vtlinit(speakerFileName)
%VTLINIT Initializes the VocalTractLabApi with a speaker file

libName = 'VocalTractLabApi';
if ~libisloaded(libName)
    loadlibrary(libName, [libName, '.h']);
    disp(['Loaded library: ' libName]);
end

if ~libisloaded(libName)
    error(['Failed to load external library: ' libName]);
end

% Init the variable version with enough characters for the version string
% to fit in.
version = '                                ';
version = calllib(libName, 'vtlGetVersion', version);

disp(['Compile date of the library: ' version]);

failure = calllib(libName, 'vtlInitialize', speakerFileName);
if (failure ~= 0)
    disp('Error in vtlInitialize()!');   
    return;
end


end

