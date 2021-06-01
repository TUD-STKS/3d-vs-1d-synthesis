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
            if ispc
                vtl.libName = "VocalTractLabApi";
            elseif isunix
                vtl.libName = "libVocalTractLabApi";
            end
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
        
        function initialize(obj)
            %INITIALIZE Initializes the VocalTractLab API library
            if ~libisloaded(obj.libName)
                if ispc
                    loadlibrary(obj.libName, obj.libName + ".h");
                elseif isunix
                    loadlibrary(obj.libName, extractAfter(obj.libName, "lib") + ".h");
                end
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
        
        function close(obj)
            % CLOSE Cleans up and unloads the VocalTractLab API library
            calllib(obj.libName, 'vtlClose');
            unloadlibrary(obj.libName);
            disp(obj.libName + " unloaded.")
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
        
        function export_tract_svg(obj, tract_params, base_file_name)
            % Exports a series of tract shapes to an SVG file
            % TRACT_PARAMS must have one row per shape
            % BASE_FILE_NAME should include the path and the prefix of the
            % filename, but not the extension.
            constants = obj.get_constants();
            if size(tract_params, 2) ~= constants.n_tract_params
                error("Number of columns does not match number of vocal tract parameters!")
            end 
            for k = 1:size(tract_params, 1)
                tractParams = tract_params(k, :);
                fileName = string(base_file_name) + "_" + num2str(k) + ".svg";
                failure = ...
                calllib(obj.libName, 'vtlExportTractSvg', tractParams, char(fileName));
                if failure ~= 0
                    error('Could not export SVG file!');
                end
            end
        end
        
        function tube_data = tract_params_to_tube_data(obj, tract_params)
            constants = obj.get_constants();
            if size(tract_params, 2) ~= constants.n_tract_params
                error("Number of columns does not match number of vocal tract parameters!")
            end 
            tube_data = table();
            for k = 1:size(tract_params, 1)
                tractParams = tract_params(k, :);
                tubeLength_cm = zeros(1, constants.n_tube_sections);
                tubeArea_cm2 = zeros(1, constants.n_tube_sections);
                tubeArticulator = zeros(1, constants.n_tube_sections);
                incisorPos_cm = 0.0;
                tongueTipSideElevation = 0.0;
                velumOpening_cm2 = 0.0;
                [failure, tractParams, tubeLength_cm, ...
                    tubeArea_cm2, tubeArticulator, incisorPos_cm, ...
                    tongueTipSideElevation, velumOpening_cm2] = ...
                calllib(obj.libName, 'vtlTractToTube', ...
                tractParams, tubeLength_cm, tubeArea_cm2, ...
                tubeArticulator, incisorPos_cm, tongueTipSideElevation, ...
                velumOpening_cm2);
                if failure ~= 0
                    error('Something went wrong in vtlTractToTube!');
                end
                tube_data = [tube_data; {tubeLength_cm, tubeArea_cm2, ...
                    tubeArticulator, incisorPos_cm, tongueTipSideElevation, ...
                    velumOpening_cm2}];
                
            end
            tube_data.Properties.VariableNames = {'tube_length_cm', 'tube_area_cm2', ...
                'tube_articulator', 'incisor_pos_cm', 'tongue_tip_side_elevation', ...
                'velum_opening_cm2'};
        end
        
        function load_speaker_file(obj, speakerFileName)
            obj.close();
            obj.speakerFileName = speakerFileName;
            obj.initialize();
        end
              
        function parameters = shape(obj, shapeName)
            parameters = zeros(1, obj.numVocalTractParams);

            [failure, ~, parameters] = ...
            calllib(obj.libName, 'vtlGetTractParams', shapeName, parameters);

            if(failure)
                error('Could not retrieve the shape parameters!')
            end
        end
               
        function opts = default_transfer_function_options(obj)
            opts = struct('spectrumType', 0, 'radiationType', 0, 'boundaryLayer', false, ...
                    'heatConduction', false, 'softWalls', false, 'hagenResistance', false, ...
                    'innerLengthCorrections', false, 'lumpedElements', false, 'paranasalSinuses', false, ...
                    'piriformFossa', false, 'staticPressureDrops', false);

            [~, opts] = ... 
                calllib(obj.libName, 'vtlGetDefaultTransferFunctionOptions', opts);
        end
        
        function [tf, f] = get_transfer_function(obj, tract_params, n_spectrum_samples, opts)
            mag = zeros(1, n_spectrum_samples);
            phase = zeros(1, n_spectrum_samples);
            [failed, ~, opts, mag, phase] = ...
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
        
        function synthesis_reset(obj)
            failure = calllib(obj.libName, 'vtlSynthesisReset');
            if failure ~= 0
                error('Something went wrong in vtlSynthesisReset!');
            end
        end
        
        function audio = synthesis_add_tube(obj, tube_data, glottis_params, n_new_samples)
            numNewSamples = n_new_samples;
            audio = zeros(1, numNewSamples);
            if size(tube_data,1 ) > 1
                warning('More than one rows of tube data passed. I will only use the first state/row!');
            end
            tubeLength_cm = tube_data.tube_length_cm(1,:);
            tubeArea_cm2 = tube_data.tube_area_cm2(1, :);
            tubeArticulator = tube_data.tube_articulator(1,:);
            incisorPos_cm = tube_data.incisor_pos_cm(1);
            velumOpening_cm = tube_data.velum_opening_cm(1);
            tongueTipSideElevation = tube_data.tongue_tip_side_elevation(1);
            newGlottisParams = glottis_params;
            [failure, audio, tubeLength_cm, tubeArea_cm2, tubeArticulator, ...
                newGlottisParams] = ... 
                calllib(obj.libName, 'vtlSynthesisAddTube', ...
                numNewSamples, audio, tubeLength_cm, tubeArea_cm2, ...
                tubeArticulator, incisorPos_cm, velumOpening_cm, ...
                tongueTipSideElevation, newGlottisParams);
            if failure ~= 0
                error('Something went wrong in vtlSynthesisAddTube!');
            end
        end
        
        function audio = synthesis_add_state(obj, tract_state, glottis_state, n_new_samples)
            numNewSamples = n_new_samples;
            audio = zeros(1, numNewSamples);
            tractParams = tract_state;
            glottisParams = glottis_state;
            [failure, audio, tractParams, glottisParams] = ...
                calllib(obj.libName, 'vtlSynthesisAddTract', ...
                numNewSamples, audio, tractParams, glottisParams);
            if failure ~= 0
                error('Something went wrong in vtlSynthesisAddTract!');
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
        
        function segment_sequence_to_gestural_score(obj, segFileName, gesFileName)
            [failure, segFileName, gesFileName] = calllib(obj.libName, ...
                'vtlSegmentSequenceToGesturalScore', segFileName, gesFileName);
            if failure ~= 0
                error('Something went wrong in vtlSegmentSequenceToGesturalScore!');
            end
            if obj.verbose
                disp("Created gestural score from file: " + string(segFileName));
            end
        end
        
        function audio = gesturalScoreToAudio(obj, ges_file_path, varargin)
            addOptional(p, 'audio_file_path', '');
            addOptional(p, 'return_audio', true);
            addOptional(p, 'return_n_samples', false);
            parse(p, varargin{:});
            if audio_file_path == '' && return_audio == false
                warning('Function returns nothing. Either pass an output audio file path or set return_audio to true!');
            end
            wavFileName = audio_file_path;
            gesFileName = ges_file_path;
            if return_audio
                audio = zeros(1, 22); % Figure out the expected size of the returned audio
            else
            end
            
            error('TODO: Function not implemented yet!');
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

