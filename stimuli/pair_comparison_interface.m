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
## 		1	   |   2    |   3    |    4   |      5     |      6     |   7    |    8   |
## participant | groupe | idSon1 | idSon2 | nbPlaySnd1 | nbPlaySnd2 | result | retest |
#fileNames = {"a_m.wav", "i_m.wav", "u_m.wav", "a_f.wav", "i_f.wav", "u_f.wav"};

## generate structure containing the file names, the sound names,
## the groupe names, the number of stimuli types, the number of
## pairs, the indexes of the pairs (1 to num of pairs), the index
## of the pair currently tested, the data to save in the csv file 
nStimuli = 14;
nPairs = 3*nStimuli;
dataStruct = struct (...
"currTrainingPair", 1, ...
"dirStimuli", "dev", ...
"fileNames", ...
{{"a_m_1D_0_25_1024_HF.wav", "i_m_1D_0_16_1024_HF.wav", "u_m_1D_0_16_1024_HF.wav", ...
"@_m_1D_0_20_1024_HF.wav", "f_m_1D_0_240_1024_HF.wav", "s_m_1D_0_220_1024_HF.wav",...
"S_m_1D_0_218_1024_HF.wav", ...
"a_f_1D_0_20_1024_HF.wav", "i_f_1D_0_18_1024_HF.wav", "u_f_1D_0_12_1024_HF.wav", ...
"@_f_1D_0_16_1024_HF.wav", "f_f_1D_0_236_1024_HF.wav", "s_f_1D_0_222_1024_HF.wav",...
"S_f_1D_0_199_1024_HF.wav", ...
"a_m_3D_0_25_1024_HF.wav", "i_m_3D_0_16_1024_HF.wav", "u_m_3D_0_16_1024_HF.wav",...
"@_m_3D_0_20_1024_HF.wav", "f_m_3D_0_240_1024_HF.wav", "s_m_3D_0_220_1024_HF.wav",...
"S_m_3D_0_218_1024_HF.wav",...
"a_f_3D_0_20_1024_HF.wav", "i_f_3D_0_18_1024_HF.wav", "u_f_3D_0_12_1024_HF.wav",...
"@_f_3D_0_16_1024_HF.wav", "f_f_3D_0_236_1024_HF.wav", "s_f_3D_0_222_1024_HF.wav",...
"S_f_3D_0_199_1024_HF.wav",...
"E_m_3D_0_23_1024_HF.wav", "sh_m_1D_0_211_1024_inf_HF.wav",... 	# training stimuli
"E_m_1D_0_23_1024_HF.wav", "sh_m_1D_0_211_1024_inf_HF.wav",...  # training stimuli
}}, ...
"sndNames", ...
{{"a_1D_m", "i_1D_m", "u_1D_m", "@_1D_m", "f_1D_m", "s_1D_m", "sh_1D_m",...
"a_1D_f", "i_1D_f", "u_1D_f", "@_1D_f", "f_1D_f", "s_1D_f", "sh_1D_f",...
"a_3D_m", "i_3D_m", "u_3D_m", "@_3D_m", "f_3D_m", "s_3D_m", "sh_3D_m",...
"a_3D_f", "i_3D_f", "u_3D_f", "@_3D_f", "f_3D_f", "s_3D_f", "sh_3D_f"}}, ...
"grpNames", {{"different", "same 1D", "same 3D"}}, ...
"nStimuli", nStimuli, "nPairs", 2*nPairs, "pairs", [1:nPairs 1:nPairs], "pairTested", 1, ...
"testData", zeros(2*nPairs, 9), "hDifferent", 0, "csvFile", ...
sprintf("participant_%d.csv", subject), ...
"csvFile_ordered",sprintf("participant_%d_ordered.csv", subject),"comaSeparator", ";");

##nStimuli = 2;
##nPairs = 3*nStimuli;
##dataStruct = struct (...
##"currTrainingPair", 1, 
##"fileNames", ...
##{{"a_1D_f=170.wav", "i_1D_f=170.wav",...
##"a_3D_f=170.wav", "i_3D_f=170.wav",...
##"@_1D_f=170.wav", "s_1D_212_f=220.wav",... 	# training stimuli
##"@_3D_f=170.wav", "s_3D_212_f=220.wav",...  # training stimuli
##}}, ...
##"sndNames", ...
##{{"a_1D_m", "i_1D_m", ...
##"a_3D_m", "i_3D_m"}}, ...
##"grpNames", {{"different", "same 1D", "same 3D"}}, ...
##"nStimuli", nStimuli, "nPairs", 2*nPairs, "pairs", [1:nPairs 1:nPairs], "pairTested", 1, ...
##"testData", zeros(2*nPairs, 9), "hDifferent", 0, "csvFile", ...
##sprintf("participant_%d.csv", subject), ...
##"csvFile_ordered",sprintf("participant_%d_ordered.csv", subject),"comaSeparator", ";");



## generate the first random pair
pairId = ceil(rand()*length(dataStruct.pairs));
pairOrder = round(rand());

dataStruct.testData(:,1) = subject;
dataStruct.testData(:,7) = -1;
dataStruct.testData(:,8) = 0;
dataStruct.testData(dataStruct.pairTested, 2) = ...
ceil(dataStruct.pairs(pairId)/dataStruct.nStimuli);

## save index of the pair tested
dataStruct.testData(dataStruct.pairTested, 9) = dataStruct.pairs(pairId);

if dataStruct.testData(dataStruct.pairTested, 2) == 1
	if pairOrder == 1
		dataStruct.testData(dataStruct.pairTested, 3) = dataStruct.pairs(pairId) + dataStruct.nStimuli;
		dataStruct.testData(dataStruct.pairTested, 4) = dataStruct.pairs(pairId);
	else
		dataStruct.testData(dataStruct.pairTested, 3) = dataStruct.pairs(pairId);
		dataStruct.testData(dataStruct.pairTested, 4) = dataStruct.pairs(pairId) + dataStruct.nStimuli;
	endif
else
	dataStruct.testData(dataStruct.pairTested, 3) = dataStruct.pairs(pairId) - dataStruct.nStimuli;
	dataStruct.testData(dataStruct.pairTested, 4) = dataStruct.pairs(pairId) - dataStruct.nStimuli;
endif
dataStruct.pairs = [dataStruct.pairs(1:pairId-1) dataStruct.pairs(pairId+1:end)];

## store the information of the training in the second line of the data structure
dataStruct.pairTested = 2;
dataStruct.testData(2, 3) = 2*dataStruct.nStimuli +  dataStruct.currTrainingPair;
dataStruct.testData(2, 4) = 2*dataStruct.nStimuli + dataStruct.currTrainingPair + 2;

###############################################
##  CALLBACKS
###############################################

function playSound1 (hObject, eventdata)
	st = guidata(hObject);
	set(hObject, "backgroundcolor", [0/255 85/255 212/255], "fontweight", "bold");
	set(st.hSon2, "backgroundcolor", [1 1 1], "fontweight", "bold");
	[y, fs] = audioread (st.fileNames{st.testData(st.pairTested, 3)});
	sound ([y ; zeros(2*4410, 1)], fs);
	st.testData(st.pairTested, 5) = st.testData(st.pairTested, 5) + 1; # number of times Son1
	guidata(hObject, st);
end

# # # # # # # # # # # # # # # # # # # # # # # # 

function playSound2 (hObject, eventdata)
	st = guidata(hObject);
	set(hObject, "backgroundcolor", [0/255 85/255 212/255], "fontweight", "bold"); 
	set(st.hSon1, "backgroundcolor", [1 1 1], "fontweight", "bold");
	[y, fs] = audioread (st.fileNames{st.testData(st.pairTested, 4)});
	sound ([y ; zeros(2*4410,1)], fs);
	st.testData(st.pairTested, 6) += 1; # number of times Son2
	guidata(hObject, st);
end

# # # # # # # # # # # # # # # # # # # # # # # # 

function rateSame(hObject, eventdata)
	st = guidata(hObject);
	st.testData(st.pairTested,7) = 0;
	guidata(hObject, st);
	set(hObject, "backgroundcolor", [0/255 85/255 212/255], "fontweight", "bold");
	set(st.hDifferent, "backgroundcolor", [1 1 1], "fontweight", "bold");
end

# # # # # # # # # # # # # # # # # # # # # # # # 

function rateDifferent(hObject, eventdata)
	st = guidata(hObject);
	st.testData(st.pairTested,7) = 1;
	guidata(hObject, st);
	set(hObject, "backgroundcolor", [0/255 85/255 212/255], "fontweight", "bold");
	set(st.hSame, "backgroundcolor", [1 1 1], "fontweight", "bold");
end

# # # # # # # # # # # # # # # # # # # # # # # # 

## training is done using the second line of testData matrix
## which is reinitialised after the training
function nextPairTraining(hObject, eventdata)

	dataStruct = guidata(hObject);

	## check if the previous pair have been rated
	if sum(dataStruct.testData(dataStruct.pairTested, 5:6)) < 2

		errordlg (sprintf("Veuillez cliquer sur les boutons \n[Son 1] et [Son 2] pour �couter les sons � comparer."));
		
	elseif dataStruct.testData(dataStruct.pairTested, 7) == -1
		
		errordlg (sprintf("Veuillez cliquer sur les boutons \n[Identiques] ou [Differents]."));

	else
		if dataStruct.currTrainingPair < 2

			dataStruct.currTrainingPair ++;

			## reinitialise line 2
			dataStruct.testData(2, 2:end) = 0;
			dataStruct.testData(2, 7) = -1;

			## set the information of training pair 
			dataStruct.testData(2, 3) = 2*dataStruct.nStimuli + dataStruct.currTrainingPair;
			dataStruct.testData(2, 4) = 2*dataStruct.nStimuli + dataStruct.currTrainingPair + 2;

			set(dataStruct.textNumPair, "string", sprintf("Paire %d sur 2", ...
			dataStruct.currTrainingPair));

			guidata(hObject, dataStruct);
      
      ## reset selected buttons highlight
	  	set(dataStruct.hDifferent, "backgroundcolor", [1 1 1]);
		  set(dataStruct.hSame, "backgroundcolor", [1 1 1]);
		  set(dataStruct.hSon2, "backgroundcolor", [1 1 1]);
	  	set(dataStruct.hSon1, "backgroundcolor", [1 1 1]);
      
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
	  	set(dataStruct.hDifferent, "backgroundcolor", [1 1 1]);
		  set(dataStruct.hSame, "backgroundcolor", [1 1 1]);
		  set(dataStruct.hSon2, "backgroundcolor", [1 1 1]);
	  	set(dataStruct.hSon1, "backgroundcolor", [1 1 1]);
		endif
	endif
end

# # # # # # # # # # # # # # # # # # # # # # # # 

function nextPair (hObject, eventdata)

	dataStruct = guidata(hObject);

	## check if the previous pair have been rated
	if sum(dataStruct.testData(dataStruct.pairTested, 5:6)) < 2

		errordlg (sprintf("Veuillez cliquer sur les boutons \n[Son 1] et [Son 2] pour �couter les sons � comparer."));
		
	elseif dataStruct.testData(dataStruct.pairTested, 7) == -1
		
		errordlg (sprintf("Veuillez cliquer sur les boutons \n[Identiques] ou [Diff�rents]."));

	else

		if length(dataStruct.pairs) >= 1

			dataStruct.pairTested = dataStruct.pairTested + 1;

			pairId = ceil(rand()*length(dataStruct.pairs));
			pairOrder = round(rand());

			## save index of the pair tested
			dataStruct.testData(dataStruct.pairTested, 9) = dataStruct.pairs(pairId);

			## check if the pair have already been tested
			idx = 1; reTest = false;
			while idx < dataStruct.pairTested
#				printf("Curr pair %d, pair idx %d\n", dataStruct.testData(dataStruct.pairTested, 9),...
#					dataStruct.testData(idx, 9));fflush(stdout);

				if dataStruct.testData(dataStruct.pairTested, 9) == dataStruct.testData(idx, 9)
					reTest = true;
					## copy the group
					dataStruct.testData(dataStruct.pairTested, 2) = dataStruct.testData(idx, 2);
					## copy the stimuli of the pair repeated
					dataStruct.testData(dataStruct.pairTested, 3) = dataStruct.testData(idx, 3);
					dataStruct.testData(dataStruct.pairTested, 4) = dataStruct.testData(idx, 4);
					## set as re-test
					dataStruct.testData(dataStruct.pairTested, 8) = 1;
					break;
				endif
				idx ++;
			endwhile

			## if the pair is tested for the first time determine the 
			## group and the stimuli composing the pair 
			if not(reTest)

				## determine the group of the pair
				dataStruct.testData(dataStruct.pairTested, 2) = ...
				ceil(dataStruct.pairs(pairId)/dataStruct.nStimuli);

				## if it is the first group it is a pair of stimuli 1D and 3D
				if dataStruct.testData(dataStruct.pairTested, 2) == 1
					## put randomly the 1D or the 3D stimulus first
					if pairOrder == 1
						dataStruct.testData(dataStruct.pairTested, 3) = dataStruct.pairs(pairId) + ...
						dataStruct.nStimuli;
						dataStruct.testData(dataStruct.pairTested, 4) = dataStruct.pairs(pairId);
					else
						dataStruct.testData(dataStruct.pairTested, 3) = dataStruct.pairs(pairId);
						dataStruct.testData(dataStruct.pairTested, 4) = dataStruct.pairs(pairId) + ...
						dataStruct.nStimuli;
					endif
				else
				## for the two other groups
					dataStruct.testData(dataStruct.pairTested, 3) = dataStruct.pairs(pairId) - ...
					dataStruct.nStimuli;
					dataStruct.testData(dataStruct.pairTested, 4) = dataStruct.pairs(pairId) - ...
					dataStruct.nStimuli;
				endif
			endif

#			printf("Stimuli %d and %d \n", dataStruct.testData(dataStruct.pairTested, 3), ...
#				dataStruct.testData(dataStruct.pairTested, 4));fflush(stdout);

			## remove the pair tested from the pair list
			dataStruct.pairs = [dataStruct.pairs(1:pairId-1) dataStruct.pairs(pairId+1:end)];

			## save result
			fid = fopen(dataStruct.csvFile, "w");
			sep = dataStruct.comaSeparator;
			fputs(fid, sprintf("Participant%sGroupe%sSon1%sSon2%snb ecoute son1%snb ecoute son2%sre-test%sevaluation%sreference\n", sep, sep, sep, sep, sep, sep, sep, sep));
		
			## loop over the pairs
			for ii = 1:(dataStruct.pairTested - 1) 
				str = sprintf("%d%s%s%s%s%s%s%s%d%s%d%s%d%s%d%s%d\n", ...
				dataStruct.testData(ii,1), sep, ...
				dataStruct.grpNames{dataStruct.testData(ii,2)}, sep, ...
				dataStruct.sndNames{dataStruct.testData(ii,3)}, sep, ...
				dataStruct.sndNames{dataStruct.testData(ii,4)}, sep, ...
				dataStruct.testData(ii,5), sep, ...
				dataStruct.testData(ii,6), sep, dataStruct.testData(ii,8), sep, ...
				dataStruct.testData(ii,7), sep, dataStruct.testData(ii,2) == 1);
				fputs(fid, str);
			endfor
			fclose(fid);

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
			fputs(fid, sprintf("Participant%sGroupe%sSon1%sSon2%snb ecoute son1%snb ecoute son2%sre-test%sevaluation%sreference\n", sep, sep, sep, sep, sep, sep, sep, sep));
		
			## loop over the pairs
			for ii = 1:dataStruct.nPairs
				str = sprintf("%d%s%s%s%s%s%s%s%d%s%d%s%d%s%d%s%d\n", ...
				dataStruct.testData(ii,1), sep, ...
				dataStruct.grpNames{dataStruct.testData(ii,2)}, sep, ...
				dataStruct.sndNames{dataStruct.testData(ii,3)}, sep, ...
				dataStruct.sndNames{dataStruct.testData(ii,4)}, sep, ...
				dataStruct.testData(ii,5), sep, ...
				dataStruct.testData(ii,6), sep, dataStruct.testData(ii,8), sep, ...
				dataStruct.testData(ii,7), sep, dataStruct.testData(ii,2) == 1);
				fputs(fid, str);
			endfor
			fclose(fid);
			set(dataStruct.textNumPair, "string", "Termin�!");
			#X = dataStruct.X; Y = dataStruct.Y;
			set(dataStruct.textQuestion, "string", "Donn�es enregistr�es");
			set(dataStruct.textOu, "visible", "off");
			set(dataStruct.hSon1, "visible", "off");
			set(dataStruct.hSon2, "visible", "off");
			set(dataStruct.hDifferent, "visible", "off");
			set(dataStruct.hSame, "visible", "off");
			set(hObject, "visible", "off");
      
      fid1 = fopen(dataStruct.csvFile);
      t = textscan(fid1,"%s %s %s %s %s %s %s %s %s", 'delimiter', sep);
      fclose(fid1);
      
      m = cell2mat(t);
      idxa = strcmp({m{:,2}},'same 1D');
      a = sortrows(m(idxa,:),3);   # sort accordding to phonemes
      idxb = strcmp({m{:,2}},'same 3D');
      b = sortrows(m(idxb,:),3);
      idxc = strcmp({m{:,2}},'different')
      c = sortrows(m(idxc,:),3);
      res = [a;b;c];
      
      idx = strcmp({res{:,7}},'1'); % find data of retest
      res_retest = res(idx,:);
      res = res(~idx,:);
      result = [res(:,1:6) res(:,8) res_retest(:,5:6) res_retest(:,8:9)]; 
      
      fid2 = fopen(dataStruct.csvFile_ordered, "w");
      fputs(fid2, sprintf("%s%s%s%stest%stest%stest%sre-test%sre-test%sre-test%s\n", sep,sep, sep, sep, sep, sep, sep, sep, sep,sep));
      fputs(fid2, sprintf("Participant%sGroupe%sSon1%sSon2%snb ecoute son1%snb ecoute son2%sevaluation%snb ecoute son1%snb ecoute son2%sevaluation%sreference\n", sep,sep, sep, sep, sep, sep, sep, sep, sep,sep));
      
      #cell2csv ('participant_1_ordered.csv', result, ";");
      
      for i = 1:size(result,1)
        str = sprintf("%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n", ...
        result{i,1}, sep, ...
        result{i,2}, sep, ...
        result{i,3}, sep, ...
        result{i,4}, sep, ...
        result{i,5}, sep, ...
        result{i,6}, sep, ...
        result{i,7}, sep, ...
        result{i,8}, sep, ...
        result{i,9}, sep,...
        result{i,10},sep,...
        result{i,11});
        fputs(fid2, str);
      endfor
      fclose(fid2);
		endif
		
		## reset selected buttons highlight
		set(dataStruct.hDifferent, "backgroundcolor", [1 1 1]);
		set(dataStruct.hSame, "backgroundcolor", [1 1 1]);
		set(dataStruct.hSon2, "backgroundcolor", [1 1 1]);
		set(dataStruct.hSon1, "backgroundcolor", [1 1 1]);
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
"Les sons sont-ils ?", ...
"units","normalized","position",[0.3 0.5 0.4 0.1],...
 "backgroundcolor", [1 1 1], "fontunits","normalized","fontsize", 0.9*normFtSize);

dataStruct.textOu = uicontrol (h, "style", "text", "string", ...
"ou", ...
"units","normalized","position",[0.34 0.35 0.3 0.1],...
 "backgroundcolor", [1 1 1],"fontunits","normalized","fontsize", normFtSize);


###############################################
##  BUTTONS
###############################################

dataStruct.hSon1 = uicontrol (h, "string", "Son 1", ...
"units","normalized","position",[0.3 0.72 0.19 0.08], ...
"callback", {@playSound1}, "fontunits","normalized","fontsize", normFtSize);
dataStruct.hSon2 = uicontrol (h, "string", "Son 2", ...
"units","normalized","position",[0.5 0.72 0.19 0.08], ...
"callback", {@playSound2}, "fontunits","normalized","fontsize", normFtSize);

dataStruct.hSame = uicontrol (h, "string", "Identiques", ...
"units","normalized","position",[0.09 0.35 0.19 0.08],...
"callback", {@rateSame}, "fontunits","normalized","fontsize", normFtSize);
dataStruct.hDifferent = uicontrol (h, "string", "Diff�rents", ...
"units","normalized","position",[0.7 0.35 0.19 0.08],...
"callback", {@rateDifferent}, "fontunits","normalized","fontsize", normFtSize);


dataStruct.next = uicontrol (h, "string", "Paire suivante", ...
"units","normalized","position",[0.65 0.18 0.25 0.08],...
"callback", @nextPairTraining, "fontunits","normalized","fontsize", normFtSize);


guidata(h, dataStruct);

