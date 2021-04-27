classdef VTL < handle
    %VTL A MATLAB wrapper for the VocalTractLab API
    
    properties
        libName
        samplerate_audio
        samplerate_internal
        speakerFileName
        state_samples
        state_duration
        verbose
    end
    
    methods
        function vtl = VTL(speakerFileName)
            %VTL Construct an instance of the VTL API
            %   Detailed explanation goes here
            vtl.speakerFileName = speakerFileName;
            vtl.libName = "VocalTractLabApi";
            vtl.state_samples = 110; % Processing rate in VTL (samples), currently 1 vocal tract state evaluation per 110 audio samples
            vtl.samplerate_audio = 44100; % Global audio sampling rate (44100 Hz default)
            vtl.samplerate_internal = vtl.samplerate_audio / vtl.state_samples; % Internal tract samplerate (ca. 400.9090... default)
            vtl.state_duration = 1 / vtl.samplerate_internal; % Processing rate in VTL (time), currently 2.49433... ms
            vtl.verbose = true;
            vtl.initialize();
        end
        
        function delete(obj)
            % DELETE Destructor of the class. 
            obj.close();
        end
        
        function close(obj)
            % CLOSE Cleans up and unloads the VocalTractLab API library
            calllib(obj.libName, 'vtlClose');
            unloadlibrary(obj.libName);
            disp(obj.libName + " unloaded.")
        end
        
        function c = get_constants(obj)
            c = struct();
            c.audioSamplingRate = 0;
            c.n_tube_sections = 0;
            c.n_tract_params = 0;
            c.n_glottis_params = 0;

            [failure, c.audioSamplingRate, c.n_tube_sections, c.n_tract_params, c.n_glottis_params] = ...
                calllib(obj.libName, 'vtlGetConstants', c.audioSamplingRate, c.n_tube_sections, c.n_tract_params, c.n_glottis_params);
            if(failure)
                 error("Could not retrieve constants in 'get_constants'!")
            end
        end
        
        function p_info = get_param_info(obj, params)
            if ~any(params == ["tract", "glottis"])
                disp("Unknown key in 'get_param_info'. Key must be 'tract' or 'glottis'. Returning 'tract' info now.");
                params = "tract";
            end
            if params == "tract"
                key = "n_tract_params";
                endpoint = "vtlGetTractParamInfo";
            elseif params == "glottis"
                key = "n_glottis_params";
                endpoint = "vtlGetGlottisParamInfo";
            end
            constants = obj.get_constants();
            % Reserve 32 chars for each parameter.
            names = blanks(constants.(key)*32);
            paramMin = zeros(1, constants.(key));
            paramMax = zeros(1, constants.(key));
            paramNeutral = zeros(1, constants.(key));
            
            [failure, names, paramMin, paramMax, paramNeutral] = ...
            calllib(obj.libName, endpoint, names, paramMin, ...
            paramMax, paramNeutral);
            
            if failure ~= 0
                error("Could not retrieve parameter info in 'get_param_info'!");
            end
            rowNames = split(names);
            p_info = table(paramMin', paramMax', paramNeutral', ...
                'VariableNames', {'min', 'max', 'neutral'}, ...
                'RowNames', rowNames);
            disp(p_info);
        end
        
        function param = get_tract_params_from_shape(obj, shape)
            c = obj.get_constants();
            param = zeros(1, c.n_tract_params);

            [failure, ~, param] = ...
              calllib(obj.libName, 'vtlGetTractParams', char(shape), param);

            if(failure)
                error('Could not retrieve the shape parameters!')
            end

        end
        
        function version = get_version(obj)
            % Init the variable version with enough characters for the version string
            % to fit in.
            version = '                                ';
            version = calllib(obj.libName, 'vtlGetVersion', version);
            if obj.verbose
                disp(['Compile date of the library: ' version]);
            end
        end
        
        function initialize(obj)
            %INITIALIZE Initializes the VocalTractLab API library
            if ~libisloaded(obj.libName)
                loadlibrary(obj.libName, obj.libName + ".h");
               disp(['Loaded library: ' obj.libName]);
            end
            
            if ~libisloaded(obj.libName)
                error(['Failed to load external library: ' obj.libName]);
            end
               
            failure = calllib(obj.libName, 'vtlInitialize', obj.speakerFileName);
            if (failure ~= 0)
                disp('Error in vtlInitialize()!');   
                return;
            end
            
            if obj.verbose
                disp('VTL successfully initialized.');
            end
        end
        
        function load_speaker_file(obj, speakerFileName)
            obj.close();
            obj.speakerFileName = speakerFileName;
            obj.initialize();
        end
        
        function opts = opts(obj)
            opts = struct('type', 0, 'radiation', 0, 'boundaryLayer', false, ...
                    'heatConduction', false, 'softWalls', false, 'hagenResistance', false, ...
                    'innerLengthCorrections', false, 'lumpedElements', false, 'paranasalSinuses', false, ...
                    'piriformFossa', false, 'staticPressureDrops', false);

            [~, opts] = ... 
                calllib(obj.libName, 'vtlGetDefaultTransferFunctionOptions', opts);
        end
        
        function parameters = shape(obj, shapeName)
            parameters = zeros(1, obj.numVocalTractParams);

            [failure, ~, parameters] = ...
            calllib(obj.libName, 'vtlGetTractParams', shapeName, parameters);

            if(failure)
                error('Could not retrieve the shape parameters!')
            end
        end
        
        function audio = synth_block(obj, tract_params, glottis_params, varargin)
            p = inputParser;
            addOptional(p, 'verbose', true);
            addOptional(p, 'state_samples', obj.state_samples);
            parse(p, varargin{:});
            constants = obj.get_constants();
            if size(tract_params, 2) ~= constants.n_tract_params
                error("Number of columns does not match number of vocal tract parameters!")
            end
            if size(glottis_params, 2) ~= constants.n_glottis_params
                error("Number of columns does not match number of glottis parameters!")
            end
            if size(tract_params, 1) ~= size(glottis_params, 1)
                disp( 'TODO: Warning: Length of tract_params and glottis_params do not match. Will modify glottis_params to match.')
                % Todo: Match length
            end
            numFrames = size(tract_params, 1);
            tractParams = reshape(tract_params.', 1, []);
            glottisParams = reshape(glottis_params.', 1, []);
            frameStep_samples = p.Results.state_samples;
            audio = zeros(1, numFrames * frameStep_samples);
            enableConsoleOutput = p.Results.verbose;
            [failure, ~, ~, audio] = calllib(obj.libName, 'vtlSynthBlock', tractParams, ...
                glottisParams, numFrames, frameStep_samples, audio, ...
                enableConsoleOutput);
            if failure ~= 0
                error("Error in 'synth_block'!");
            end
            
        end
        
        function [tf, f] = get_transfer_function(obj, tract_params, n_spectrum_samples, opts)
            mag = zeros(1, n_spectrum_samples);
            phase = zeros(1, n_spectrum_samples);
            [failed, ~, mag, phase] = ...
            calllib(obj.libName, 'vtlGetTransferFunction', tract_params, ...
                n_spectrum_samples, opts, mag, phase);

            if (failed)
                error('Could not retrieve vocal tract transfer function!')
            end
            tf = mag .* exp(1i*phase);
            % Returned transfer function should be column vector
            tf = tf.';
            f = [0:n_spectrum_samples-1]*obj.samplerate_audio / n_spectrum_samples;
        end
        
        function save_transfer_function(~, fileName, tf, f)
            if length(tf) ~= length(f)
                error('Mismatch of length of transfer function and frequency vector!');
            end
            fileID = fopen(fileName,'w');
            fprintf(fileID, '%s %d\n', 'num_points:', length(tf));
            fprintf(fileID, '%s  %s  %s\n', 'frequency_Hz', 'magnitude', 'phase_rad');
            for i = 1:length(f)
                fprintf(fileID, '%f  %f  %f\n', f(i), abs(tf(i)), angle(tf(i)));
            end            
            fclose(fileID);
        end
    end
end

