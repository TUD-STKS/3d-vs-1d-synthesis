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
  
  warndlg(sprintf("Le fichier <participant\\_%d.csv> existe d�j�.", subject));

end
## test data
##    	1		   |   2    |   3    |    4   |      5     |      6     |   7    |    8   |    9     |   10  | 
## participant | groupe | idSon1 | idSon2 | nbPlaySnd1 | nbPlaySnd2 | result | retest | idx pair | order |
##                                                                                                 pair

##      11      |
## snd selected |

## generate structure containing the file names, the sound names,
## the groupe names, the number of stimuli types, the number of
## pairs, the indexes of the pairs (1 to num of pairs), the index
## of the pair currently tested, the data to save in the csv file 

testMode = true;

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
  "testData", zeros(2*nPairs, 11), "hSon2MostNatural", 0, "csvFile", ...
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
	set(st.hSon1, "backgroundcolor", [0/255 85/255 212/255], "fontweight", "bold");
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
	set(st.hSon2, "backgroundcolor", [0/255 85/255 212/255], "fontweight", "bold"); 
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
  ## indicate that sound 1 have been selected as the most natural
  st.testData(st.pairTested, 11) = 1;
  ## indicate if the hypothesis (ex 3D more natural than bwe) 
  ## is verified (1) or not (0)
  if st.testData(st.pairTested, 10) == 1
    st.testData(st.pairTested,7) = 1;
	else
    st.testData(st.pairTested,7) = 0;
  endif
	guidata(hObject, st);
	set(hObject, "backgroundcolor", [0/255 85/255 212/255], "fontweight", "bold");
	set(st.hSon2MostNatural, "backgroundcolor", [1 1 1], "fontweight", "normal");
  
##  ## go to next pair
##  st.currTrainingPair;
##  if st.currTrainingPair < 3
##    nextPairTraining(hObject, eventdata);
##  else
##    nextPair(hObject, eventdata);
##  end
end

# # # # # # # # # # # # # # # # # # # # # # # # 

function rateSon2MostNatural(hObject, eventdata)
	st = guidata(hObject);
  ## indicate that sound 2 have been selected as the most natural
  st.testData(st.pairTested, 11) = 2;
  ## indicate if the hypothesis (ex 3D more natural than bwe) 
  ## is verified (1) or not (0)
  if st.testData(st.pairTested, 10) == 1
    st.testData(st.pairTested,7) = 0;
	else
    st.testData(st.pairTested,7) = 1;
  endif
	guidata(hObject, st);
	set(hObject, "backgroundcolor", [0/255 85/255 212/255], "fontweight", "bold");
	set(st.hSon1MostNatural, "backgroundcolor", [1 1 1], "fontweight", "normal");
  
##  ## go to next pair
##  st.currTrainingPair;
##  if st.currTrainingPair < 3
##    nextPairTraining(hObject, eventdata);
##  else
##    nextPair(hObject, eventdata);
##  end
end

# # # # # # # # # # # # # # # # # # # # # # # # 

function writeRawDataToCsv(hObject, eventdata)
  dataStruct = guidata(hObject);
  fid = fopen(dataStruct.csvFile, "w");
  sep = dataStruct.comaSeparator;

  ## generate header
  fputs(fid, ["Participant" sep ...
  "Sound 1" sep ...
  "Sound 2" sep ...
  "Gender" sep ...
  "Vowel" sep ...
  "Voice quality" sep ...
  "Pair type" sep ...
  "Condition 1" sep ...
  "Condition 2" sep ...
  "Num listen snd 1" sep ...
  "Num listen snd 2" sep ...
##  "pair order" sep ...
  "re-test" sep ...
  "Selected snd" sep ...
  "Evaluation\n"]); 

  ## loop over the pairs
  for ii = 1:(dataStruct.pairTested) 
    ## extract data from file name
    fileName1 = dataStruct.fileNames{dataStruct.testData(ii,3)};
    gender = fileName1(1);
    vowel = fileName1(3);
    [o1, o2, o3, voiceQuality] = regexp(fileName1, "[^_.]{5,7}");
    [o1, o2, o3, condition1] = regexp(fileName1, "MM_[^_]{2,3}");
    fileName2 = dataStruct.fileNames{dataStruct.testData(ii,4)};
    [o1, o2, o3, condition2] = regexp(fileName2, "MM_[^_]{2,3}");
    
    ## write data in csv file
    str = [num2str(dataStruct.testData(ii,1)) sep ... participant
    dataStruct.sndNames{dataStruct.testData(ii,3)} sep ... sound 1
    dataStruct.sndNames{dataStruct.testData(ii,4)} sep ... sound 2
    gender sep ...                                         gender
    vowel sep ...                                          vowel
    voiceQuality{1} sep ...                               voice quality
    dataStruct.grpNames{dataStruct.testData(ii,2)} sep ... pair type
    condition1{1}(4:end) sep ...                      condition 1
    condition2{1}(4:end) sep ...                      condition 2
    num2str(dataStruct.testData(ii,5)) sep ... nb ecoute sound 1
    num2str(dataStruct.testData(ii,6)) sep ... nb ecoute sound 2
##    num2str(dataStruct.testData(ii,10)) sep ... pair order
    num2str(dataStruct.testData(ii,8)) sep ... retest
    num2str(dataStruct.testData(ii,11)) sep ... selected sound
    num2str(dataStruct.testData(ii,7)) sep ... evaluation
    sprintf("\n")];
    fputs(fid, str);
  endfor
  fclose(fid);  
end

# # # # # # # # # # # # # # # # # # # # # # # # 

## training is done using the second line of testData matrix
## which is reinitialised after the training
function nextPairTraining(hObject, eventdata)

	dataStruct = guidata(hObject);

	## check if the previous pair have been rated
	if or(dataStruct.testData(dataStruct.pairTested, 5) == 0,
    dataStruct.testData(dataStruct.pairTested, 6) == 0) 

		errordlg (sprintf("Veuillez cliquer sur les boutons \n[Son 1] et [Son 2] pour �couter les sons � comparer."));
		
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
      
##      ## play sounds
##      playSound1 (hObject, eventdata);
##      playSound2 (hObject, eventdata);
      
      ## reset selected buttons highlight
	  	set(dataStruct.hSon2MostNatural, "backgroundcolor", [1 1 1], "fontweight", "normal");
		  set(dataStruct.hSon1MostNatural, "backgroundcolor", [1 1 1], "fontweight", "normal");
		  set(dataStruct.hSon2, "backgroundcolor", [1 1 1], "fontweight", "normal");
	  	set(dataStruct.hSon1, "backgroundcolor", [1 1 1], "fontweight", "normal");
      
		else
      
      dataStruct.currTrainingPair ++;
      
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
      
##      ## play sounds
##      playSound1 (hObject, eventdata);
##      playSound2 (hObject, eventdata);
      
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
		errordlg (sprintf("Veuillez cliquer sur les boutons \n[Son 1] et [Son 2] pour �couter les sons � comparer."));
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
        
        ## the order of the pair (ex 1D then 3D, or 3D then 1D) is also set randomly
			  pairOrder = round(rand());
        dataStruct.testData(dataStruct.pairTested, 10) = pairOrder; 
        
        ## determine the index of one of the stimuli of the pair
        idxStimulus = ceil(dataStruct.pairs(pairId) / 3);

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

			## remove the pair tested from the pair list
			dataStruct.pairs = [dataStruct.pairs(1:pairId-1) dataStruct.pairs(pairId+1:end)];

			## save result
      writeRawDataToCsv(hObject, eventdata);

			## display advancement
			set(dataStruct.textNumPair, "string", sprintf("Paire %d sur %d", ...
			dataStruct.pairTested, dataStruct.nPairs));
			guidata(hObject, dataStruct);
      
##      ## play sounds
##      playSound1 (hObject, eventdata);
##      playSound2 (hObject, eventdata);

		else
    
      writeRawDataToCsv(hObject, eventdata);
      
			set(dataStruct.textNumPair, "string", "Termin�!");
			#X = dataStruct.X; Y = dataStruct.Y;
			set(dataStruct.textQuestion, "string", "Donn�es enregistr�es");
			set(dataStruct.hSon1, "visible", "off");
			set(dataStruct.hSon2, "visible", "off");
			set(dataStruct.hSon2MostNatural, "visible", "off");
			set(dataStruct.hSon1MostNatural, "visible", "off");
			set(hObject, "visible", "off");
      
      ###########################################
      ## Order the test data in another csv file
      ###########################################
      
      fid1 = fopen(dataStruct.csvFile);
      sep = dataStruct.comaSeparator;
      t = textscan(fid1,"%s %s %s %s %s %s %s %s %s %s %s %s %s %s", 'delimiter', sep);
      fclose(fid1);
      
      ## sort data
      m = cell2mat(t);
      idxa = strcmp({m{:,7}},'MM-1D');
      a = sortrows(m(idxa,:), 3);   # sort accordding to phonemes and gender
      a = sortrows(a,6);            # sort according to voice quality
      idxb = strcmp({m{:,7}},'MM-BWE');
      b = sortrows(m(idxb,:),3);    # sort accordding to phonemes and gender
      b = sortrows(b, 6);           # sort according to voice quality
      idxc = strcmp({m{:,7}},'1D-BWE');
      c = sortrows(m(idxc,:),3);    # sort accordding to phonemes and gender
      c = sortrows(c, 6);           # sort according to voice quality
      res = [a;b;c];
      
      ## find data of retest
      idx = strcmp({res{:,12}},'1'); 
      res_retest = res(idx,:);
      res = res(~idx,:);
      result = [res(:,1:11) res(:,14) res_retest(:,10:11) res_retest(:,14)]; 
      
      fid2 = fopen(dataStruct.csvFile_ordered, "w");

      ## generate header
      fputs(fid2, [sep ...
      sep ...
      sep ...
      sep ...
      sep ...
      sep ...
      sep ...
      sep ...
      sep ...
      "Test" sep ...
      "Test" sep ...
      "Test" sep ...
      "Re-test" sep ...
      "Re-test" sep ...
      "Re-test\n"]);

      fputs(fid2, ["Participant" sep ...
      "Sound 1" sep ...
      "Sound 2" sep ...
      "Gender" sep ...
      "Vowel" sep ...
      "Voice quality" sep ...
      "Pair type" sep ...
      "Condition 1" sep ...
      "Condition 2" sep ...
      "Num listen snd 1" sep ...
      "Num listen snd 2" sep ...
      "Evaluation" sep ... 
      "Num listen snd 1" sep ...
      "Num listen snd 2" sep ...
      "Evaluation\n"]);
      
      ## write data
      for i = 1:size(result,1)
        fputs(fid2, [result{i,1} sep ... Participant
        result{i,2} sep ... Sound 1
        result{i,3} sep ... Sound 2
        result{i,4} sep ... Gender
        result{i,5} sep ... Vowel
        result{i,6} sep ... Voice quality
        result{i,7} sep ... Pair type
        result{i,8} sep ... Condition 1
        result{i,9} sep ... Condition 2
        result{i,10} sep ... Num listen snd 1
        result{i,11} sep ... Num listen snd 2
        result{i,12} sep ... Evaluation
        result{i,13} sep ... Num listen snd 1
        result{i,14} sep ... Num listen snd 2
        result{i,15} "\n"]); ## Evaluation
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
"callback", @nextPairTraining, "fontunits","normalized","fontsize", normFtSize,...
"visible", "on");


guidata(h, dataStruct);

