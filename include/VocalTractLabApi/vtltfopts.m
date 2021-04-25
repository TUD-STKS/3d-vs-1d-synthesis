function opts = vtltfopts()
%VTLTFOPTS Returns a struct with the default transfer function options.

libName = 'VocalTractLabApi';

opts = struct('type', 0, 'radiation', 0, 'boundaryLayer', false, ...
'heatConduction', false, 'softWalls', false, 'hagenResistance', false, ...
'innerLengthCorrections', false, 'lumpedElements', false, 'paranasalSinuses', false, ...
'piriformFossa', false, 'staticPressureDrops', false);

[~, opts] = ...
  calllib(libName, 'vtlGetDefaultTransferFunctionOptions', opts);

end

