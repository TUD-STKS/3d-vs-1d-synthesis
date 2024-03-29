## Graphical interface for sound evaluation 

clear all
close all
clc


###############################################
##  MAIN FIGURE
###############################################

bgcolor = [240/255 248/255 255/255];
h = figure("units", "normalized","position",[0.15 0.15 0.7 0.7], "toolbar", ...
"auto","color",bgcolor);  
#guidata(h, dataStruct);

###############################################
##  DATA INITIALIZATION
###############################################

## get the number of the subject
prompt = {"Participant: "};
rowscols = [1];
hs = inputdlg (prompt, "Entrer le numero du participant", rowscols) ;	
subject = str2num(hs{1});
if exist(sprintf("participant_%d.csv", subject),'file')!=0
  warndlg(sprintf("Le fichier <participant\\_%d.csv> existe d�j��.", subject));
end


## test data
## 		1	   |   2    |   3    |    4   |      5     |  
## participant | evaluation | nbSon | idSon | retest |

## generate structure containing the file names, sound names,
## the number of stimuli types,  
## the index of the stimuli currently tested, the data to save in the csv file,
## the index of the stimuli currently tested, comma separator.

testMode = false;
if testMode
  nStimuli = 2;
  dataStruct = struct (
  "dirStimuli", "dev/",
  "files", {{ "f_a_MM_MM_modal.wav", ...
  "m_a_MM_MM_modal.wav", ...
  "m_Y_MM_bwe_pressed.wav", "m_Y_MM_MM_modal.wav",... 	# training stimuli
  }}, ...
  "sndNames", ...
  {{"f_a_MM", "m_a_MM", "m_u_MM", "m_o_MM"}}, ...
  "nStimuli",2*nStimuli,"stimuliTested", 1, "stimuli",[1:nStimuli 1:nStimuli],...
  "testData", zeros(2*nStimuli,5),"currTrainingStimuli",1,...
  "comaSeparator", ";",...
  "csvFile_ordered",sprintf("participant_%d_ordered.csv", subject));
else
  vowels = {"a", "e", "i", "o", "u"};
  model = {"MM", "1d", "bwe"};
  gender = {"f", "m"};
  voiceQuality = {"modal", "pressed"};
  nStimuli = 60;
  strCreateDataStruct = ["dataStruct = struct (""dirStimuli"", ""dev/"", ""files"", {{"];
  strSndNames = [];
  for v = 1:5
    for m = 1:3
      for g = 1:2
        for q = 1:2
          strCreateDataStruct = [strCreateDataStruct ...
          sprintf("""%s_%s_MM_%s_%s.wav"",", gender{g}, vowels{v}, model{m},...
          voiceQuality{q})];
          strSndNames = [strSndNames sprintf(...
          """%s_%s_%s_%s"",", gender{g}, vowels{v}, model{m}, voiceQuality{q})];
        end
      end
    end
  end
  strCreateDataStruct = [strCreateDataStruct ...
  """m_Y_MM_bwe_pressed.wav"", ""m_Y_MM_1d_modal.wav""}}, "...
  """sndNames"", {{" strSndNames """m_a_MM_modal"", ""f_a_1d_modal""}}," ...
  """nStimuli"", " num2str(2*nStimuli) ", ""stimuliTested"", 1, ""stimuli"","...
  "[1:nStimuli 1:nStimuli], ""testData"", zeros(2*nStimuli,5)," ...
  """currTrainingStimuli"", 1, ""comaSeparator"", "";"", "...
  """csvFile_ordered"", sprintf(""participant_%d_ordered.csv"", subject));"];
  eval(strCreateDataStruct);
end

dataStruct.testData(:,1) = subject;  # participant
dataStruct.testData(:,2) = -1;       # evaluation, "-1" means the current sound has not been evaluated.
dataStruct.testData(:,3) = 0;        # number of times
dataStruct.testData(:,5) = 0;
guidata(h, dataStruct);

## generate the first random stimuli
stimuliId = ceil(rand()*length(dataStruct.stimuli));
## save index of the stimuli tested
dataStruct.testData(dataStruct.stimuliTested, 4) = dataStruct.stimuli(stimuliId);
dataStruct.stimuli = [dataStruct.stimuli(1:stimuliId-1) dataStruct.stimuli(stimuliId+1:end)];
## store the information of the training in the second line of the data structure
dataStruct.stimuliTested = 2;

dataStruct.testData(2, 4) = nStimuli + dataStruct.currTrainingStimuli;

###############################################
##  CALLBACKS
###############################################

function playSound (hObject, eventdata)
	data = guidata(hObject);
	set(hObject, "backgroundcolor", [70/255 130/255 180/255], "fontweight", "bold");
	[y, fs] = audioread ([data.dirStimuli data.files{data.testData(data.stimuliTested, 4)}]);
  player = audioplayer(y, fs);
  playblocking(player);
  set(hObject, "backgroundcolor", [192/255 192/255 192/255], "fontweight", "bold");
  data.testData(data.stimuliTested,3) += 1;
  guidata(hObject, data);
end
###################################
function rateSound(hObject,eventdata)
  st = guidata(hObject);
  st.testData(st.stimuliTested,2) = get (st.ratingSlider, "value");
  set(st.next, "enable", "on");
  guidata(hObject, st);
end
###################################
function saveRawDataAsCsv(hObject,eventdata)
  dataStruct = guidata(hObject);
  csvFile = sprintf("participant_%d.csv", dataStruct.testData(1,1));
  fid = fopen(csvFile, "w");
  sep = dataStruct.comaSeparator;

  ## Generate header
  fputs(fid, ["Participant" sep ...
  "File name" sep ...
  "Gender" sep ...
  "Vowel" sep ...
  "Voice quality" sep ...
  "Condition" sep ...
  "Num listen" sep ...
  "Re-test" sep ...
  "Evaluation\n"]);
  
  ## Write data
  for ii = 1:(dataStruct.stimuliTested)
    ## extract data from file name
    fileName = dataStruct.files{dataStruct.testData(ii,4)};
    gender = fileName(1);
    vowel = fileName(3);
    [o1, o2, o3, voiceQuality] = regexp(fileName, "[^_.]{5,7}");
    [o1, o2, o3, condition] = regexp(fileName, "MM_[^_]{2,3}");
    ## write data in csv file
    fputs(fid, [num2str(dataStruct.testData(ii,1)) sep...  Participant
    fileName sep ...                                                          File name
    gender sep ...                                                              gender
    vowel sep ...                                                                vowel
    voiceQuality{1} sep ...                                            voice quality
    condition{1}(4:end) sep ...                                    condition
    num2str(dataStruct.testData(ii,3)) sep ...      Num listen
    num2str(dataStruct.testData(ii,5)) sep ...      Re-test
    num2str(dataStruct.testData(ii,2)) "\n"]); ##        Evaluation
  endfor
  fclose(fid);
end
###################################
function nextTraining(hObject, eventdata)
  dataStruct = guidata(hObject);
  if dataStruct.testData(dataStruct.stimuliTested, 3) == 0

		errordlg (sprintf("Veuillez cliquer sur le bouton [Son] pour �couter le son."));
		
	elseif dataStruct.testData(dataStruct.stimuliTested, 2) == -1
		
		errordlg (sprintf("Veuillez positionner le curseur."));
	else
    if dataStruct.currTrainingStimuli < 2

	    dataStruct.currTrainingStimuli ++;

		  ## reinitialise line 2
		  dataStruct.testData(2, 3:end) = 0;
		  dataStruct.testData(2, 2) = -1;

		  ## set the information of training pair 
		  dataStruct.testData(2, 4) = dataStruct.nStimuli/2 + dataStruct.currTrainingStimuli;

      set(dataStruct.textNumPair, "string", sprintf("SON %d / 2", ...
      dataStruct.currTrainingStimuli));
      set(dataStruct.ratingSlider, 'value', 0.5)

		  guidata(hObject, dataStruct);
      set(hObject, "enable", "off");
      playSound (hObject, eventdata);
    else
			## reinitialise line 2
			dataStruct.testData(2, 3:end) = 0;
			dataStruct.testData(2, 2) = -1;
      dataStruct.stimuliTested = 1;
      set(dataStruct.ratingSlider, 'value', 0.5)

			## display advancement
			set(dataStruct.textTraining, "visible", "off");
			set(dataStruct.textNumPair, "string", sprintf("SON %d / %d", ...
      dataStruct.stimuliTested, dataStruct.nStimuli));

			set(dataStruct.next, "callback", @next);
			guidata(hObject, dataStruct);
      set(hObject, "enable", "off");
      playSound (hObject, eventdata)
		endif
  endif
    
end

function next(hObject, eventdata)
  dataStruct = guidata(hObject);
  if dataStruct.testData(dataStruct.stimuliTested, 3) == 0

		errordlg (sprintf("Veuillez cliquer sur le bouton [Son] pour �couter le son."));
		
	elseif dataStruct.testData(dataStruct.stimuliTested, 2) == -1
		
		errordlg (sprintf("Veuillez positionner le curseur."));

	else
    if length(dataStruct.stimuli) >= 1

			dataStruct.stimuliTested += 1;

			stimuliId = ceil(rand()*length(dataStruct.stimuli));

			## update fileID
      dataStruct.testData(dataStruct.stimuliTested, 4) = dataStruct.stimuli(stimuliId);
      
      ## check if the stimulus has already been tested
			idx = 1;
			while idx < dataStruct.stimuliTested

				if dataStruct.testData(dataStruct.stimuliTested, 4) == dataStruct.testData(idx, 4)
					## set as re-test
					dataStruct.testData(dataStruct.stimuliTested, 5) = 1;
					break;
				endif
				idx ++;
			endwhile


      
      ##remove the stimulus tested from the stimuli list
      dataStruct.stimuli = [dataStruct.stimuli(1:stimuliId-1) dataStruct.stimuli(stimuliId+1:end)];
      
      ## save result
      saveRawDataAsCsv(hObject,eventdata);
      
      set(dataStruct.textNumPair, "string", sprintf("SON %d / %d", ...
      dataStruct.stimuliTested, dataStruct.nStimuli));
      set(dataStruct.ratingSlider, 'value', 0.5);

      guidata(hObject,dataStruct);
      set(hObject, "enable", "off");
      playSound (hObject, eventdata)
      
      ## Change name of next button for last pair
			if length(dataStruct.stimuli) == 0
				set(hObject, "String", "Enregistrer");
			endif
    else
      
      saveRawDataAsCsv(hObject,eventdata);

      set(dataStruct.ratingSlider, "visible", "off");
      set(dataStruct.next,"visible", "off");
      set(dataStruct.hSon,"visible", "off");
      set(dataStruct.textTotallyNatural,"visible", "off");
      set(dataStruct.graduations, "visible", "off");
      set(dataStruct.textNumPair, "string", "Termin�!");
      set(dataStruct.textNotNatural,"string","Donn�es enregistr�es",...
      "units", "normalized","position",[0.3 0.5 0.4 0.1]);
      
      #################################
      ## Order the data in human  readable way 
      #################################
      
      csvFile = sprintf("participant_%d.csv", dataStruct.testData(1,1));
      sep = dataStruct.comaSeparator;
      fid1 = fopen(csvFile);
      t = textscan(fid1,"%s %s %s %s %s %s %s %s %s", 'delimiter', sep);
      fclose(fid1);
      
      m = cell2mat(t);
##      res = sortrows(m(2:end,:),2);
      res = sortrows(m(2:end,:),4); # sort according to phoneme
      res = sortrows(res, 3);       # sort according to gender
      res = sortrows(res, 5);       # sort according to voice quality
      res = sortrows(res, 6);       # sort acording to condition
      
      idx = strcmp({res{:,8}},'1');
      res_retest = res(idx,:);
      res = res(~idx,:);
      result = [res(:,1:7) res(:,9) res_retest(:,7) res_retest(:,9)];
      
      fid2 = fopen(dataStruct.csvFile_ordered, "w");
      ## generate header
      fputs(fid2, [sep ...
      sep ...
      sep ...
      sep ...
      sep ...
      sep ...
      "Test" sep ...
      "Test" sep ...
      "Re-test" sep ...
      "Re-test\n"]);
      fputs(fid2, ["participant" sep ...
      "File name" sep ...
      "Gender" sep ...
      "Vowel" sep ...
      "Voice quality" sep ...
      "Condition" sep ...
      "Num listen" sep ...
      "Evaluation" sep ...
      "Num listen" sep ...
      "Evaluation\n"]);
      ## write data
      for i = 1:size(result,1)
        fputs(fid2, [result{i,1} sep ...
        result{i,2} sep ...
        result{i,3} sep ...
        result{i,4} sep ...
        result{i,5} sep ...
        result{i,6} sep ...
        result{i,7} sep ...
        result{i,8} sep ...
        result{i,9} sep ...
        result{i,10} "\n"]);
      endfor
      fclose(fid2);
      
      guidata(hObject,dataStruct);
     endif
  endif
end




###############################################
##  TEXTS
###############################################

normalizedFtSize = 0.5;

dataStruct.textNumPair = uicontrol (h, "style", "text", "string", ...
sprintf("SON %d / 2", dataStruct.currTrainingStimuli), ...
"units", "normalized","position",[0.35 0.8 0.3 0.1],...
"backgroundcolor",bgcolor,"fontunits","normalized", "fontsize", normalizedFtSize,...
"foregroundcolor", [0 0 0],...
"fontweight","bold");

dataStruct.textTraining = uicontrol (h, "style", "text", "string", ...
"Entrainement", ...
"units", "normalized","position",[0.35 0.9 0.3 0.1],...
"backgroundcolor",bgcolor,"fontunits","normalized", "fontsize", normalizedFtSize,...
 "foregroundcolor", [1 0 0],"fontweight","bold");

dataStruct.textNotNatural = uicontrol (h, "style", "text", "string", ...
"pas du tout\nnaturel", "units", "normalized",...
"position",[0.01 0.6 0.2 0.2], "backgroundcolor", bgcolor, ...
"fontunits","normalized","fontsize", 0.5*normalizedFtSize,...
"fontweight","bold","units", "normalized","foregroundcolor", [0 0 0]);

dataStruct.textTotallyNatural = uicontrol (h, "style", "text", "string", ...
"totalement\nnaturel", ...
"units", "normalized","position",[0.72 0.6 0.3 0.2],...
"fontunits","normalized","fontsize", 0.5*normalizedFtSize,...
"backgroundcolor", bgcolor, "fontweight","bold",...
"foregroundcolor", [0 0 0]);

###############################################
## SLIDER
###############################################

dataStruct.ratingSlider = uicontrol ("style", "slider",
                            "units", "normalized",
                            "string", "slider",
                            "callback", @rateSound,
                            "value", 0.5,
                            "position", [0.1 0.5 0.78 0.05]);
                            
###############################################
## SLIDER GRADUATIONS
###############################################

dataStruct.graduations = axes("position", [0.145 0.48 0.69 0.05],
##"color", [0.9, 0.95, 1],
"xtick", [0:10:100],
"xticklabel", {"0", "", "", "", "", "50", "", "", "", "", "100"},
"ytick", [],
"xlim", [0, 100],
"ylim", [0, 1],
"fontsize", 18);

###############################################
##  BUTTONS
###############################################

dataStruct.hSon = uicontrol (h, "string", "Ecouter", ...
"units", "normalized","position",[0.4 0.7 0.2 0.1], ...
"callback", {@playSound}, "fontunits","normalized","fontsize", normalizedFtSize,...
"backgroundcolor",[192/255 192/255 192/255],...
"foregroundcolor", [0 0 0],"fontweight","bold");
 
dataStruct.next = uicontrol (h, "string", "suivant",...
"backgroundcolor", [192/255 192/255 192/255],...
 "units","normalized","position",[0.4 0.2 0.2 0.1],...
 "foregroundcolor", [0 0 0],"fontunits","normalized",...
 "fontsize", normalizedFtSize,
 "callback", {@nextTraining}, "fontweight","bold");

guidata(h, dataStruct);