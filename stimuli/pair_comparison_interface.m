## Graphical interface for pairwise comparison 

clear all
close all
clc
###############################################
##  MAIN FIGURE
###############################################

#X = 800; Y = 600; ftSize = 22;
normFtSize = 0.5;

#h = figure("position", [200    100    X    Y], "toolbar", "none");
h = figure("units","normalized","position", [0.2    0.1    0.6    0.8], "toolbar", "none");

## get the number of the subject
prompt = {"Participant: "};
rowscols = [1];
hs = inputdlg (prompt, "Entrer le numero du participant", rowscols) ;	
subject = str2num(hs{1});
if exist(sprintf("participant_%d.csv", subject),'file')!=0
  
  warndlg(sprintf("Le fichier <participant\\_%d.csv> existe déjà.", subject));

end
## test data
##    	1		   |   2    |   3    |    4   |      5     |      6     |   7    |    8   |    9     |   10  | 
## participant | groupe | idSon1 | idSon2 | nbPlaySnd1 | nbPlaySnd2 | result | retest | idx pair | order |
##                                                                                                 pair

## generate structure containing the file names, the sound names,
## the groupe names, the number of stimuli types, the number of
## pairs, the indexes of the pairs (1 to num of pairs), the index
## of the pair currently tested, the data to save in the csv file 

##nStimuli = 14;
##nPairs = 3*nStimuli;
##dataStruct = struct (...
##"currTrainingPair", 1, ...
##"dirStimuli", "dev", ...
##"fileNames", ...
##{{"a_m_1D_0_25_1024_HF.wav", "i_m_1D_0_16_1024_HF.wav", "u_m_1D_0_16_1024_HF.wav", ...
##"@_m_1D_0_20_1024_HF.wav", "f_m_1D_0_240_1024_HF.wav", "s_m_1D_0_220_1024_HF.wav",...
##"S_m_1D_0_218_1024_HF.wav", ...
##"a_f_1D_0_20_1024_HF.wav", "i_f_1D_0_18_1024_HF.wav", "u_f_1D_0_12_1024_HF.wav", ...
##"@_f_1D_0_16_1024_HF.wav", "f_f_1D_0_236_1024_HF.wav", "s_f_1D_0_222_1024_HF.wav",...
##"S_f_1D_0_199_1024_HF.wav", ...
##"a_m_3D_0_25_1024_HF.wav", "i_m_3D_0_16_1024_HF.wav", "u_m_3D_0_16_1024_HF.wav",...
##"@_m_3D_0_20_1024_HF.wav", "f_m_3D_0_240_1024_HF.wav", "s_m_3D_0_220_1024_HF.wav",...
##"S_m_3D_0_218_1024_HF.wav",...
##"a_f_3D_0_20_1024_HF.wav", "i_f_3D_0_18_1024_HF.wav", "u_f_3D_0_12_1024_HF.wav",...
##"@_f_3D_0_16_1024_HF.wav", "f_f_3D_0_236_1024_HF.wav", "s_f_3D_0_222_1024_HF.wav",...
##"S_f_3D_0_199_1024_HF.wav",...
##"E_m_3D_0_23_1024_HF.wav", "sh_m_1D_0_211_1024_inf_HF.wav",... 	# training stimuli
##"E_m_1D_0_23_1024_HF.wav", "sh_m_1D_0_211_1024_inf_HF.wav",...  # training stimuli
##}}, ...
##"sndNames", ...
##{{"a_1D_m", "i_1D_m", "u_1D_m", "@_1D_m", "f_1D_m", "s_1D_m", "sh_1D_m",...
##"a_1D_f", "i_1D_f", "u_1D_f", "@_1D_f", "f_1D_f", "s_1D_f", "sh_1D_f",...
##"a_3D_m", "i_3D_m", "u_3D_m", "@_3D_m", "f_3D_m", "s_3D_m", "sh_3D_m",...
##"a_3D_f", "i_3D_f", "u_3D_f", "@_3D_f", "f_3D_f", "s_3D_f", "sh_3D_f"}}, ...
##"grpNames", {{"different", "same 1D", "same 3D"}}, ...
##"nStimuli", nStimuli, "nPairs", 2*nPairs, "pairs", [1:nPairs 1:nPairs], "pairTested", 1, ...
##"testData", zeros(2*nPairs, 9), "hSon2MostNatural", 0, "csvFile", ...
##sprintf("participant_%d.csv", subject), ...
##"csvFile_ordered",sprintf("participant_%d_ordered.csv", subject),"comaSeparator", ";");

testMode = false;

if testMode
  ## To test the interface with a minimal number of stimuli
  nStimuli = 2;
  nPairs = 3*nStimuli;
  dataStruct = struct (...
  "currTrainingPair", 1, 
  "dirStimuli", "dev/", ...
  "fileNames", ...
  {{"f_a_MM_MM_modal.wav", "f_e_MM_MM_modal.wav",...
  "f_a_MM_1d_modal.wav", "f_e_MM_1d_modal.wav",...
  "f_a_MM_bwe_modal.wav", "f_e_MM_bwe_modal.wav",...
  "m_a_MM_bwe_modal.wav",... 	# training stimuli
  "m_a_MM_1d_modal.wav",...  # training stimuli
  "m_a_MM_MM_modal.wav",...  # training stimuli
  }}, ...
  "sndNames", ...
  {{"f_a_MM", "f_e_MM",...
  "f_a_1d", "f_e_1d",...
  "f_a_bwe", "f_e_bwe"}}, ...
  "grpNames", {{"MM-1D", "MM-BWE", "1D-BWE"}}, ...
  "nStimuli", nStimuli, "nPairs", 2*nPairs, "pairs", [1:nPairs 1:nPairs], "pairTested", 1, ...
  "testData", zeros(2*nPairs, 10), "hSon2MostNatural", 0, "csvFile", ...
  sprintf("participant_%d.csv", subject), ...
  "csvFile_ordered",sprintf("participant_%d_ordered.csv", subject),"comaSeparator", ";");
else
  nStimuli = 20;
  model = {"MM", "1d", "bwe"};
  nPairs = 3*nStimuli;
  vowels = {"a","e","i","o","u"};
  gender = {"f","m"};
  voiceQuality = {"modal", "pressed"};
  strCreateDataStruct = "dataStruct = struct (""currTrainingPair"", 1, ""dirStimuli"", ""dev/"", ""fileNames"", {{";
  strSndNames = [];
  ## generate file names
  for m = 1:3
    for g = 1:2
      for q = 1:2
        for v = 1:5
          name = sprintf("%s_%s_MM_%s_%s.wav", gender{g}, vowels{v}, model{m}, voiceQuality{q})
          strCreateDataStruct = [strCreateDataStruct """" name """, "];
          nameSnd = sprintf("%s_%s_%s_%s", gender{g}, vowels{v}, model{m}, voiceQuality{q})
          strSndNames = [strSndNames """" nameSnd ""","];
        endfor
      endfor
    endfor
  endfor
  strCreateDataStruct = [strCreateDataStruct ...
  """m_a_MM_bwe_modal.wav"", ""m_a_MM_1d_modal.wav"", ""m_a_MM_MM_modal.wav"""...
  "}},""sndNames"", {{"...
  strSndNames(1:end-1) "}}, " ...
  """grpNames"", {{""MM-1D"", ""MM-BWE"", ""1D-BWE""}},"...
  """nStimuli""," num2str(nStimuli) ", ""nPairs"", " num2str(2*nPairs)...
  ", ""pairs"", [1:nPairs 1:nPairs], ""pairTested"", 1, ""testData"", "...
  "zeros(2*nPairs, 10), ""hSon2MostNatural"", 0, ""csvFile"","...
  "sprintf(""participant_%d.csv"", subject), ""csvFile_ordered"","...
  "sprintf(""participant_%d_ordered.csv"", subject),""comaSeparator"", "";"");"]
  eval(strCreateDataStruct);
  
##  dataStruct = struct ("currTrainingPair", 1, "dirStimuli", "dev/", ...
##"fileNames",...
## {{"f_a_MM_MM_modal.wav", "f_e_MM_MM_modal.wav", "f_i_MM_MM_modal.wav",...
## "f_o_MM_MM_modal.wav", "f_u_MM_MM_modal.wav", "f_a_MM_MM_pressed.wav",...
## "f_e_MM_MM_pressed.wav", "f_i_MM_MM_pressed.wav", "f_o_MM_MM_pressed.wav",...
## "f_u_MM_MM_pressed.wav", "m_a_MM_MM_modal.wav", "m_e_MM_MM_modal.wav",...
## "m_i_MM_MM_modal.wav", "m_o_MM_MM_modal.wav", "m_u_MM_MM_modal.wav",...
## "m_a_MM_MM_pressed.wav", "m_e_MM_MM_pressed.wav", "m_i_MM_MM_pressed.wav",...
## "m_o_MM_MM_pressed.wav", "m_u_MM_MM_pressed.wav", "f_a_MM_1d_modal.wav",...
## "f_e_MM_1d_modal.wav", "f_i_MM_1d_modal.wav", "f_o_MM_1d_modal.wav",...
## "f_u_MM_1d_modal.wav", "f_a_MM_1d_pressed.wav", "f_e_MM_1d_pressed.wav",...
## "f_i_MM_1d_pressed.wav", "f_o_MM_1d_pressed.wav", "f_u_MM_1d_pressed.wav",...
## "m_a_MM_1d_modal.wav", "m_e_MM_1d_modal.wav", "m_i_MM_1d_modal.wav",...
## "m_o_MM_1d_modal.wav", "m_u_MM_1d_modal.wav", "m_a_MM_1d_pressed.wav",...
## "m_e_MM_1d_pressed.wav", "m_i_MM_1d_pressed.wav", "m_o_MM_1d_pressed.wav",...
## "m_u_MM_1d_pressed.wav", "f_a_MM_bwe_modal.wav", "f_e_MM_bwe_modal.wav",...
## "f_i_MM_bwe_modal.wav", "f_o_MM_bwe_modal.wav", "f_u_MM_bwe_modal.wav",...
## "f_a_MM_bwe_pressed.wav", "f_e_MM_bwe_pressed.wav", "f_i_MM_bwe_pressed.wav",...
## "f_o_MM_bwe_pressed.wav", "f_u_MM_bwe_pressed.wav", "m_a_MM_bwe_modal.wav",...
## "m_e_MM_bwe_modal.wav", "m_i_MM_bwe_modal.wav", "m_o_MM_bwe_modal.wav",...
## "m_u_MM_bwe_modal.wav", "m_a_MM_bwe_pressed.wav", "m_e_MM_bwe_pressed.wav",...
## "m_i_MM_bwe_pressed.wav", "m_o_MM_bwe_pressed.wav", "m_u_MM_bwe_pressed.wav"}},...
## "sndNames", {{"f_a_MM_modal","f_e_MM_modal","f_i_MM_modal","f_o_MM_modal",...
## "f_u_MM_modal","f_a_MM_pressed","f_e_MM_pressed","f_i_MM_pressed",...
## "f_o_MM_pressed","f_u_MM_pressed","m_a_MM_modal","m_e_MM_modal","m_i_MM_modal",...
## "m_o_MM_modal","m_u_MM_modal","m_a_MM_pressed","m_e_MM_pressed","m_i_MM_pressed",...
## "m_o_MM_pressed","m_u_MM_pressed","f_a_1d_modal","f_e_1d_modal","f_i_1d_modal",...
## "f_o_1d_modal","f_u_1d_modal","f_a_1d_pressed","f_e_1d_pressed","f_i_1d_pressed",...
## "f_o_1d_pressed","f_u_1d_pressed","m_a_1d_modal","m_e_1d_modal","m_i_1d_modal",...
## "m_o_1d_modal","m_u_1d_modal","m_a_1d_pressed","m_e_1d_pressed","m_i_1d_pressed",...
## "m_o_1d_pressed","m_u_1d_pressed","f_a_bwe_modal","f_e_bwe_modal","f_i_bwe_modal",...
## "f_o_bwe_modal","f_u_bwe_modal","f_a_bwe_pressed","f_e_bwe_pressed","f_i_bwe_pressed",...
## "f_o_bwe_pressed","f_u_bwe_pressed","m_a_bwe_modal","m_e_bwe_modal","m_i_bwe_modal",...
## "m_o_bwe_modal","m_u_bwe_modal","m_a_bwe_pressed","m_e_bwe_pressed","m_i_bwe_pressed",...
## "m_o_bwe_pressed","m_u_bwe_pressed"}},...
## "grpNames", {{"MM-1D", "MM-BWE", "1D-BWE"}},"nStimuli",20, "nPairs", 120, ...
## "pairs", [1:nPairs 1:nPairs], "pairTested", 1, "testData", zeros(2*nPairs, 10),...
## "hSon2MostNatural", 0, "csvFile",sprintf("participant_%d.csv", subject),...
## "csvFile_ordered",sprintf("participant_%d_ordered.csv", subject),"comaSeparator", ";");
  
endif



##################################
## generate the first random pair
##################################

## the indexes identifying the pairs are stored in dataStruct.pairs
## these identifiers are present twice in the list for reTest
## each time a pair is generated an identifier pairId is randomly picked in this list
pairId = ceil(rand()*length(dataStruct.pairs));
## the order of the pair (ex 1D then 3D, or 3D then 1D) is also set randomly
pairOrder = round(rand());
dataStruct.testData(dataStruct.pairTested, 10) = pairOrder; 

## initialise the data structure containing the results of the experiment
dataStruct.testData(:,1) = subject;
## initialise the test results with -1 which indicates that no rated has been
## yet provided to the pair
dataStruct.testData(:,7) = -1;
dataStruct.testData(:,8) = 0;
## determine the type of pair (3D-1D, 3D-BWE or 1D-BWE)
dataStruct.testData(dataStruct.pairTested, 2) = ...
mod(dataStruct.pairs(pairId), 3);
if dataStruct.testData(dataStruct.pairTested, 2)  == 0
  dataStruct.testData(dataStruct.pairTested, 2) = 3;
endif

## determine the index of one of the stimuli of the pair
idxStimulus = ceil(dataStruct.pairs(pairId)/3);

## save index of the pair tested
dataStruct.testData(dataStruct.pairTested, 9) = dataStruct.pairs(pairId);

## determine the indexes of the stimuli corresponding to the pair
switch (dataStruct.testData(dataStruct.pairTested, 2))
  ## 3D-1D
case 1
  if pairOrder == 1
    dataStruct.testData(dataStruct.pairTested, 3) = idxStimulus;
    dataStruct.testData(dataStruct.pairTested, 4) = idxStimulus + dataStruct.nStimuli;
  else
    dataStruct.testData(dataStruct.pairTested, 3) = idxStimulus + dataStruct.nStimuli;
    dataStruct.testData(dataStruct.pairTested, 4) = idxStimulus;
  endif
  ## 3D-BWE
case 2
  if pairOrder == 1
    dataStruct.testData(dataStruct.pairTested, 3) = idxStimulus;
    dataStruct.testData(dataStruct.pairTested, 4) = idxStimulus + 2*dataStruct.nStimuli;
  else
    dataStruct.testData(dataStruct.pairTested, 3) = idxStimulus + 2*dataStruct.nStimuli;
    dataStruct.testData(dataStruct.pairTested, 4) = idxStimulus;
  endif
  ## 1D-BWE
case 3
  if pairOrder == 1
    dataStruct.testData(dataStruct.pairTested, 3) = idxStimulus + dataStruct.nStimuli;
    dataStruct.testData(dataStruct.pairTested, 4) = idxStimulus + 2*dataStruct.nStimuli;
  else
    dataStruct.testData(dataStruct.pairTested, 3) = idxStimulus + 2*dataStruct.nStimuli;
    dataStruct.testData(dataStruct.pairTested, 4) = idxStimulus + dataStruct.nStimuli;
  endif
endswitch

## remove the pair which have just been created from the pair list
dataStruct.pairs = [dataStruct.pairs(1:pairId-1) dataStruct.pairs(pairId+1:end)];

## store the information of the training in the second line of the data structure
dataStruct.pairTested = 2;
dataStruct.testData(2, 3) = 3*dataStruct.nStimuli + 1;
dataStruct.testData(2, 4) = 3*dataStruct.nStimuli + 2;

###############################################
##  CALLBACKS
###############################################

function playSound1 (hObject, eventdata)
	st = guidata(hObject);
	set(hObject, "backgroundcolor", [0/255 85/255 212/255], "fontweight", "bold");
	set(st.hSon2, "backgroundcolor", [1 1 1], "fontweight", "normal");
  [st.dirStimuli st.fileNames{st.testData(st.pairTested, 3)}]
	[y, fs] = audioread ([st.dirStimuli st.fileNames{st.testData(st.pairTested, 3)}]);
  player = audioplayer(y, fs);
  playblocking(player);
	st.testData(st.pairTested, 5) = st.testData(st.pairTested, 5) + 1; # number of times Son1
	guidata(hObject, st);
end

# # # # # # # # # # # # # # # # # # # # # # # # 

function playSound2 (hObject, eventdata)
	st = guidata(hObject);
	set(hObject, "backgroundcolor", [0/255 85/255 212/255], "fontweight", "bold"); 
	set(st.hSon1, "backgroundcolor", [1 1 1], "fontweight", "normal");
  [st.dirStimuli st.fileNames{st.testData(st.pairTested, 4)}]
	[y, fs] = audioread ([st.dirStimuli st.fileNames{st.testData(st.pairTested, 4)}]);
  player = audioplayer(y, fs);
  playblocking(player);
	st.testData(st.pairTested, 6) += 1; # number of times Son2
	guidata(hObject, st);
end

# # # # # # # # # # # # # # # # # # # # # # # # 

function rateSon1MostNatural(hObject, eventdata)
	st = guidata(hObject);
  if st.testData(st.pairTested, 10) == 1
    st.testData(st.pairTested,7) = 1;
	else
    st.testData(st.pairTested,7) = 0;
  endif
	guidata(hObject, st);
	set(hObject, "backgroundcolor", [0/255 85/255 212/255], "fontweight", "bold");
	set(st.hSon2MostNatural, "backgroundcolor", [1 1 1], "fontweight", "normal");
end

# # # # # # # # # # # # # # # # # # # # # # # # 

function rateSon2MostNatural(hObject, eventdata)
	st = guidata(hObject);
  if st.testData(st.pairTested, 10) == 1
    st.testData(st.pairTested,7) = 0;
	else
    st.testData(st.pairTested,7) = 1;
  endif
	guidata(hObject, st);
	set(hObject, "backgroundcolor", [0/255 85/255 212/255], "fontweight", "bold");
	set(st.hSon1MostNatural, "backgroundcolor", [1 1 1], "fontweight", "normal");
end

# # # # # # # # # # # # # # # # # # # # # # # # 

## training is done using the second line of testData matrix
## which is reinitialised after the training
function nextPairTraining(hObject, eventdata)

	dataStruct = guidata(hObject);

	## check if the previous pair have been rated
	if or(dataStruct.testData(dataStruct.pairTested, 5) == 0,
    dataStruct.testData(dataStruct.pairTested, 6) == 0) 

		errordlg (sprintf("Veuillez cliquer sur les boutons \n[Son 1] et [Son 2] pour écouter les sons à comparer."));
		
	elseif dataStruct.testData(dataStruct.pairTested, 7) == -1
		
		errordlg (sprintf("Veuillez cliquer sur les boutons \n[Le son 1 est le plus naturel] ou [Le son 2 est le plus naturel]."));

	else
		if dataStruct.currTrainingPair < 2

			dataStruct.currTrainingPair ++;

			## reinitialise line 2
			dataStruct.testData(2, 2:end) = 0;
			dataStruct.testData(2, 7) = -1;

			## set the information of training pair 
			dataStruct.testData(2, 3) = 3*dataStruct.nStimuli + 2;
			dataStruct.testData(2, 4) = 3*dataStruct.nStimuli + 3;

			set(dataStruct.textNumPair, "string", sprintf("Paire %d sur 2", ...
			dataStruct.currTrainingPair));

			guidata(hObject, dataStruct);
      
      ## reset selected buttons highlight
	  	set(dataStruct.hSon2MostNatural, "backgroundcolor", [1 1 1], "fontweight", "normal");
		  set(dataStruct.hSon1MostNatural, "backgroundcolor", [1 1 1], "fontweight", "normal");
		  set(dataStruct.hSon2, "backgroundcolor", [1 1 1], "fontweight", "normal");
	  	set(dataStruct.hSon1, "backgroundcolor", [1 1 1], "fontweight", "normal");
      
		else
			## reinitialise line 2
			dataStruct.testData(2, 2:end) = 0;
			dataStruct.testData(2, 7) = -1;

			dataStruct.pairTested = 1;
			## display advancement
			set(dataStruct.textTraining, "visible", "off");
			set(dataStruct.textNumPair, "string", sprintf("Paire %d sur %d", ...
			dataStruct.pairTested, dataStruct.nPairs),...
			"units","normalized","position",[0.29 0.83 0.4 0.1]);

			set(dataStruct.next, "callback", @nextPair);
			guidata(hObject, dataStruct);
      ## reset selected buttons highlight
	  	set(dataStruct.hSon2MostNatural, "backgroundcolor", [1 1 1], "fontweight", "normal");
		  set(dataStruct.hSon1MostNatural, "backgroundcolor", [1 1 1], "fontweight", "normal");
		  set(dataStruct.hSon2, "backgroundcolor", [1 1 1], "fontweight", "normal");
	  	set(dataStruct.hSon1, "backgroundcolor", [1 1 1], "fontweight", "normal");
		endif
	endif
end

# # # # # # # # # # # # # # # # # # # # # # # # 

function nextPair (hObject, eventdata)

	dataStruct = guidata(hObject);

	## check if the sounds have been listened
	if or(dataStruct.testData(dataStruct.pairTested, 5) == 0,
    dataStruct.testData(dataStruct.pairTested, 6) == 0) 
		errordlg (sprintf("Veuillez cliquer sur les boutons \n[Son 1] et [Son 2] pour écouter les sons à comparer."));
  ## check if the previous pair have been rated
	elseif dataStruct.testData(dataStruct.pairTested, 7) == -1
		errordlg (sprintf("Veuillez cliquer sur les boutons \n[Le son 1 est le plus naturel] ou [Le son 2 est le plus naturel]."));
	else

		if length(dataStruct.pairs) >= 1

			dataStruct.pairTested = dataStruct.pairTested + 1;

      ## randomly select a pair to test
			pairId = ceil(rand()*length(dataStruct.pairs));

			## save index of the pair tested
			dataStruct.testData(dataStruct.pairTested, 9) = dataStruct.pairs(pairId);

			## check if the pair have already been tested
			idx = 1; reTest = false;
			while idx < dataStruct.pairTested
##				printf("Curr pair %d, pair idx %d\n", dataStruct.testData(dataStruct.pairTested, 9),...
##					dataStruct.testData(idx, 9));fflush(stdout);

				if dataStruct.testData(dataStruct.pairTested, 9) == dataStruct.testData(idx, 9)
					reTest = true;
					## copy the group
					dataStruct.testData(dataStruct.pairTested, 2) = dataStruct.testData(idx, 2);
					## copy the stimuli of the pair repeated
					dataStruct.testData(dataStruct.pairTested, 3) = dataStruct.testData(idx, 3);
					dataStruct.testData(dataStruct.pairTested, 4) = dataStruct.testData(idx, 4);
					## set as re-test
					dataStruct.testData(dataStruct.pairTested, 8) = 1;
          ## copy the order of the pair repeated
          dataStruct.testData(dataStruct.pairTested, 10) = dataStruct.testData(idx, 10);
					break;
				endif
				idx ++;
			endwhile

			## if the pair is tested for the first time determine the 
			## group and the stimuli composing the pair 
			if not(reTest)
        
        ## determine the type of pair (3D-1D, 3D-BWE or 1D-BWE)
        dataStruct.testData(dataStruct.pairTested, 2) = ...
        mod(dataStruct.pairs(pairId), 3);
        if dataStruct.testData(dataStruct.pairTested, 2)  == 0
          dataStruct.testData(dataStruct.pairTested, 2) = 3;
        endif
        dataStruct.testData(dataStruct.pairTested, 2) 
        
        ## the order of the pair (ex 1D then 3D, or 3D then 1D) is also set randomly
			  pairOrder = round(rand())
        dataStruct.testData(dataStruct.pairTested, 10) = pairOrder; 
        
        ## determine the index of one of the stimuli of the pair
        idxStimulus = ceil(dataStruct.pairs(pairId) / 3)

        ## save index of the pair tested
        dataStruct.testData(dataStruct.pairTested, 9) = dataStruct.pairs(pairId);

        ## determine the indexes of the stimuli corresponding to the pair
        switch (dataStruct.testData(dataStruct.pairTested, 2))
          ## 3D-1D
        case 1
          if pairOrder == 1
            dataStruct.testData(dataStruct.pairTested, 3) = idxStimulus;
            dataStruct.testData(dataStruct.pairTested, 4) = idxStimulus + dataStruct.nStimuli;
          else
            dataStruct.testData(dataStruct.pairTested, 3) = idxStimulus + dataStruct.nStimuli;
            dataStruct.testData(dataStruct.pairTested, 4) = idxStimulus;
          endif
          ## 3D-BWE
        case 2
          if pairOrder == 1
            dataStruct.testData(dataStruct.pairTested, 3) = idxStimulus;
            dataStruct.testData(dataStruct.pairTested, 4) = idxStimulus + 2*dataStruct.nStimuli;
          else
            dataStruct.testData(dataStruct.pairTested, 3) = idxStimulus + 2*dataStruct.nStimuli;
            dataStruct.testData(dataStruct.pairTested, 4) = idxStimulus;
          endif
          ## 1D-BWE
        case 3
          if pairOrder == 1
            dataStruct.testData(dataStruct.pairTested, 3) = idxStimulus + dataStruct.nStimuli;
            dataStruct.testData(dataStruct.pairTested, 4) = idxStimulus + 2*dataStruct.nStimuli;
          else
            dataStruct.testData(dataStruct.pairTested, 3) = idxStimulus + 2*dataStruct.nStimuli;
            dataStruct.testData(dataStruct.pairTested, 4) = idxStimulus + dataStruct.nStimuli;
          endif
        endswitch
			endif

#			printf("Stimuli %d and %d \n", dataStruct.testData(dataStruct.pairTested, 3), ...
#				dataStruct.testData(dataStruct.pairTested, 4));fflush(stdout);

			## remove the pair tested from the pair list
			dataStruct.pairs = [dataStruct.pairs(1:pairId-1) dataStruct.pairs(pairId+1:end)];

			## save result
			fid = fopen(dataStruct.csvFile, "w");
			sep = dataStruct.comaSeparator;
			fputs(fid, sprintf("Participant%sGroupe%sSon1%sSon2%snb ecoute son1%snb ecoute son2%sre-test%sevaluation%spair order\n", sep, sep, sep, sep, sep, sep, sep, sep));
		
			## loop over the pairs
			for ii = 1:(dataStruct.pairTested - 1) 
				str = sprintf("%d%s%s%s%s%s%s%s%d%s%d%s%d%s%d%s%d\n", ...
				dataStruct.testData(ii,1), sep, ...
				dataStruct.grpNames{dataStruct.testData(ii,2)}, sep, ...
				dataStruct.sndNames{dataStruct.testData(ii,3)}, sep, ...
				dataStruct.sndNames{dataStruct.testData(ii,4)}, sep, ...
				dataStruct.testData(ii,5), sep, ...
				dataStruct.testData(ii,6), sep, dataStruct.testData(ii,8), sep, ...
				dataStruct.testData(ii,7), sep, dataStruct.testData(ii,10));
				fputs(fid, str);
			endfor
			fclose(fid);
      
##      printf("\nResults saved\n")

			## display advancement
			set(dataStruct.textNumPair, "string", sprintf("Paire %d sur %d", ...
			dataStruct.pairTested, dataStruct.nPairs));
			guidata(hObject, dataStruct);

			## Change name of next button for last pair
			if length(dataStruct.pairs) == 0
				set(hObject, "String", "Enregistrer")
			endif
		else

#			csvFile = sprintf("participant_%d.csv", dataStruct.testData(1,1));
			fid = fopen(dataStruct.csvFile, "w");
			sep = dataStruct.comaSeparator;
			fputs(fid, sprintf("Participant%sGroupe%sSon1%sSon2%snb ecoute son1%snb ecoute son2%sre-test%sevaluation%spair order\n", sep, sep, sep, sep, sep, sep, sep, sep));
		
			## loop over the pairs
			for ii = 1:dataStruct.nPairs
				str = sprintf("%d%s%s%s%s%s%s%s%d%s%d%s%d%s%d%s%d\n", ...
				dataStruct.testData(ii,1), sep, ...
				dataStruct.grpNames{dataStruct.testData(ii,2)}, sep, ...
				dataStruct.sndNames{dataStruct.testData(ii,3)}, sep, ...
				dataStruct.sndNames{dataStruct.testData(ii,4)}, sep, ...
				dataStruct.testData(ii,5), sep, ...
				dataStruct.testData(ii,6), sep, dataStruct.testData(ii,8), sep, ...
				dataStruct.testData(ii,7), sep, dataStruct.testData(ii,10));
				fputs(fid, str);
			endfor
			fclose(fid);
			set(dataStruct.textNumPair, "string", "Terminé!");
			#X = dataStruct.X; Y = dataStruct.Y;
			set(dataStruct.textQuestion, "string", "Données enregistrées");
			set(dataStruct.hSon1, "visible", "off");
			set(dataStruct.hSon2, "visible", "off");
			set(dataStruct.hSon2MostNatural, "visible", "off");
			set(dataStruct.hSon1MostNatural, "visible", "off");
			set(hObject, "visible", "off");
      
      ###########################################
      ## Order the test data in another csv file
      ###########################################
      
      fid1 = fopen(dataStruct.csvFile);
      t = textscan(fid1,"%s %s %s %s %s %s %s %s %s", 'delimiter', sep);
      fclose(fid1);
      
      m = cell2mat(t);
      idxa = strcmp({m{:,2}},'MM-1D');
      a = sortrows(m(idxa,:),3);   # sort accordding to phonemes
      idxb = strcmp({m{:,2}},'MM-BWE');
      b = sortrows(m(idxb,:),3);
      idxc = strcmp({m{:,2}},'1D-BWE')
      c = sortrows(m(idxc,:),3);
      res = [a;b;c];
      
      idx = strcmp({res{:,7}},'1'); % find data of retest
      res_retest = res(idx,:);
      res = res(~idx,:);
      result = [res(:,1:6) res(:,8) res_retest(:,5:6) res_retest(:,8:9)]; 
      
      fid2 = fopen(dataStruct.csvFile_ordered, "w");
      fputs(fid2, sprintf("%s%s%s%stest%stest%stest%sre-test%sre-test%sre-test%s\n", sep,sep, sep, sep, sep, sep, sep, sep, sep,sep));
      fputs(fid2, sprintf("Participant%sGroupe%sSon1%sSon2%snb ecoute son1%snb ecoute son2%sevaluation%snb ecoute son1%snb ecoute son2%sevaluation\n", sep,sep, sep, sep, sep, sep, sep, sep, sep));
      
      #cell2csv ('participant_1_ordered.csv', result, ";");
      
      for i = 1:size(result,1)
        str = sprintf("%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n", ...
        result{i,1}, sep, ...
        result{i,2}, sep, ...
        result{i,3}, sep, ...
        result{i,4}, sep, ...
        result{i,5}, sep, ...
        result{i,6}, sep, ...
        result{i,7}, sep, ...
        result{i,8}, sep, ...
        result{i,9}, sep,...
        result{i,10});
        fputs(fid2, str);
      endfor
      fclose(fid2);
		endif
		
		## reset selected buttons highlight
		set(dataStruct.hSon2MostNatural, "backgroundcolor", [1 1 1], "fontweight", "normal");
		set(dataStruct.hSon1MostNatural, "backgroundcolor", [1 1 1], "fontweight", "normal");
		set(dataStruct.hSon2, "backgroundcolor", [1 1 1], "fontweight", "normal");
		set(dataStruct.hSon1, "backgroundcolor", [1 1 1], "fontweight", "normal");
	endif
end



###############################################
##  TEXTS
###############################################

dataStruct.textNumPair = uicontrol (h, "style", "text", "string", ...
sprintf("Paire %d sur 2", dataStruct.currTrainingPair), ...
"units","normalized","position",[0.29 0.83 0.4 0.1], ...
"backgroundcolor", [1 1 1], "fontunits","normalized","fontsize", normFtSize);

dataStruct.textTraining = uicontrol (h, "style", "text", "string", ...
"Entrainement", ...
"units","normalized","position",[0.34 0.9 0.3 0.1], ...
"backgroundcolor", [1 1 1], "fontunits","normalized","fontsize", normFtSize,...
 "foregroundcolor", [1 0 0]);

dataStruct.textQuestion = uicontrol (h, "style", "text", "string", ...
"", ...
"units","normalized","position",[0.3 0.5 0.4 0.1],...
 "backgroundcolor", [1 1 1], "fontunits","normalized","fontsize", 0.9*normFtSize);

##dataStruct.textOu = uicontrol (h, "style", "text", "string", ...
##"ou", ...
##"units","normalized","position",[0.34 0.35 0.3 0.1],...
## "backgroundcolor", [1 1 1],"fontunits","normalized","fontsize", normFtSize);


###############################################
##  BUTTONS
###############################################

dataStruct.hSon1 = uicontrol (h, "string", "Son 1", ...
"units","normalized","position",[0.3 0.72 0.19 0.08], ...
"callback", {@playSound1}, "fontunits","normalized","fontsize", normFtSize);
dataStruct.hSon2 = uicontrol (h, "string", "Son 2", ...
"units","normalized","position",[0.5 0.72 0.19 0.08], ...
"callback", {@playSound2}, "fontunits","normalized","fontsize", normFtSize);

dataStruct.hSon1MostNatural = uicontrol (h, "string", "Le son 1\n est le \nplus naturel", ...
"units","normalized","position",[0.3 0.45 0.19 0.19],...
"callback", {@rateSon1MostNatural}, "fontunits","normalized","fontsize", 0.15);
dataStruct.hSon2MostNatural = uicontrol (h, "string", "Le son 2\n est le \nplus naturel", ...
"units","normalized","position",[0.5 0.45 0.19 0.19],...
"callback", {@rateSon2MostNatural}, "fontunits","normalized","fontsize", 0.15);


dataStruct.next = uicontrol (h, "string", "Paire suivante", ...
"units","normalized","position",[0.65 0.18 0.25 0.08],...
"callback", @nextPairTraining, "fontunits","normalized","fontsize", normFtSize);


guidata(h, dataStruct);

