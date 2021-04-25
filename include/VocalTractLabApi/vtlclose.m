function vtlclose()
%VTLCLOSE Unloads the VocalTractLabApi

libName = 'VocalTractLabApi';

calllib(libName, 'vtlClose');

unloadlibrary(libName);

end

