#pragma rtGlobals=1	// Use modern global access method.
#include <Execute Cmd On List>

// These routines are based on the 'NeurIgnacio' procedures.

Menu "HEKA Loader"
	"Browse Experiments", Panel_NeurignacioBrowser()
	"Load INFO", Neurignacio_Panel()
End

function Initialize_Variables()
	SVAR S_wavenames=root:Data:S_wavenames
	WAVE/Z group,type
	String/G protocol_wave, group_items,list_experiments="",loaded_experiments=""
	String/G protocol_list,group_list,type_list, culture_list
	String/G resultswave_list="none;"
	String/G tracename=""
	Make/O/T/N=0 protocolwave,groupwave,typewave,experimentwave, culturewave
	Make/O/N=0 protocolsw,groupsw,typesw,experimentsw, culturesw
	NewDataFolder/O root:Results
	
	protocol_list=Removefromlist("name",S_wavenames)
	protocol_list=Removefromlist("group",S_wavenames)
	protocol_list=Removefromlist("type",S_wavenames)
	group_list=EnumerateItemsfromWave(root:Data:group)
	type_list=EnumerateItemsfromWave(root:Data:type)
	culture_list=EnumerateItemsfromWave(root:Data:folder)
	listtowave(protocol_list,protocolwave)
	listtowave(group_list,groupwave)
	listtowave(type_list,typewave)
	listtowave(culture_list, culturewave)
	
	Redimension/N=(numpnts(protocolwave)) protocolsw
	Redimension/N=(numpnts(groupwave)) groupsw
	Redimension/N=(numpnts(typewave)) typesw
	Redimension/N=(numpnts(culturewave)) culturesw
	
	protocolsw=32
	groupsw=32
	typesw=32
	culturesw=32
end

// -------------- PANELS AND WINDOWS ---------------------------------------

Window Neurignacio_Panel() : Panel
	String/G neurignacio_version="version b"
	String/G neurignacio_release="11.07.2021"
	
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(320,57,900,720)
	ModifyPanel cbRGB=(56576,56576,56576)
	//	ShowTools
	SetDrawLayer UserBack
	SetDrawEnv fname= "Curlz MT",fsize= 25,fstyle= 1,textxjust= 1,textyjust= 1
	DrawText 260,21,"Neuroloader "+neurignacio_version
	SetDrawEnv fname= "Matisse ITC",textxjust= 1,textyjust= 1
	DrawText 278,41,"Release "+neurignacio_release
	Button LoadINFO,pos={10,67},size={100,20},proc=ButtonProc_LoadINFO,title="Load INFO ..."

EndMacro

function Accessories()
	string/G path
	SVAR S_path=root:Data:S_path, S_filename=root:data:S_filename

	//	DrawPICT 5,112,1,1,PICT_2
	SetDrawEnv fname= "Matisse ITC",textxjust= 1,textyjust= 1
	DrawText 278,41,"Release "
	SetDrawEnv fname= "Bradley Hand ITC",fsize= 18,fstyle= 1,textxjust= 1,textyjust= 1
	DrawText 53,127,"Protocols"
	SetDrawEnv fname= "Bradley Hand ITC",fsize= 18,fstyle= 1,textxjust= 1,textyjust= 1
	DrawText 205,127,"Groups"
	SetDrawEnv fname= "Bradley Hand ITC",fsize= 18,fstyle= 1,textxjust= 1,textyjust= 1
	DrawText 299,127,"Culture"
	//	SetDrawEnv fname= "Bradley Hand ITC",fsize= 18,fstyle= 1,textxjust= 1,textyjust= 1	
	//	DrawText 139,351,"Type"
	SetDrawEnv fname= "Bradley Hand ITC",fsize= 18,fstyle= 1,textxjust= 1,textyjust= 1
	DrawText 435,127,"Experiments"

	path=S_path+S_filename
	SetVariable setvar_file,pos={4,87},size={552,15},title=" ",font="Courier New"
	SetVariable setvar_file,fSize=9,fStyle=1,value= path,noedit= 1
	ListBox protocolbox,pos={11,139},size={150,500},frame=2
	ListBox protocolbox,listWave=root:protocolwave,selWave=root:protocolsw,mode= 4
	ListBox groupbox,pos={167,139},size={88,250},frame=2,listWave=root:groupwave
	ListBox groupbox,selWave=root:groupsw,mode= 4
	ListBox typebox,pos={167,400},size={88,80},frame=2,listWave=root:typewave
	ListBox typebox,selWave=root:typesw,mode= 4
	ListBox experimentbox,pos={378,139},size={153,500},listWave=root:experimentwave
	ListBox experimentbox,selWave=root:experimentsw,row= 1,mode= 4
	ListBox folderbox,pos={260,139},size={112,350},frame=2
	ListBox folderbox,listWave=root:culturewave,selWave=root:culturesw,row= 6
	ListBox folderbox,mode= 4
	Button button_Update,pos={167,500},size={60,20},proc=UpdateButtonProc,title="Update"
	Button button_SelectAllExp,pos={167,570},size={100,20},proc=ButtonProc_SelAllExperiments,title="Select All"
	Button button_SelNoneExp,pos={272,570},size={101,20},proc=ButtonProc_SelNoneExperiments,title="Select None"
	Button button_ResetListBoxes,pos={241,600},size={61,20},proc=ButtonProc_ResetListBoxes,title="Reset"
	Button button_LoadExperiments,pos={237,500},size={125,20},proc=LoadExperiments,title="Load Selected"
	Button button_DisplayExp,pos={211,530},size={125,23},proc=Button_DisplayExp,title="Start Display"
	
	//	PopupMenu popup0,pos={180,630},size={150,20},proc= VersionPopup,title="Data Format"
	//	PopupMenu popup0,mode=1,popColor= (0,65535,65535),value="Pulse;PatchMaster"
	//	Button button_AverageSelected,pos={262,432},size={100,20},proc=ButtonProc_AverageSelected,title="Average Selected"
	//	GroupBox groupbox_Procedures,pos={15,449},size={523,92},title="Analysis Procedures"
	//	GroupBox groupbox_Procedures,labelBack=(26112,26112,0),font="Bradley Hand ITC"
	//	GroupBox groupbox_Procedures,fSize=18,fStyle=1,fColor=(65024,39424,5120)
	//	CheckBox check_Review,pos={42,482},size={100,14},title="Review Episodes"
	//	CheckBox check_Review,value= 0
	//	CheckBox check_BlankArtifact,pos={149,482},size={81,14},title="Blank Artifact"
	//	CheckBox check_BlankArtifact,value= 0,mode=1
	//	CheckBox check_Baseline,pos={246,482},size={58,14},title="Baseline"
	//	CheckBox check_Baseline,value= 0,mode=1
	//	CheckBox check_TwoRegion,pos={315,482},size={119,14},title="Two Region Baseline"
	//	CheckBox check_TwoRegion,value= 0,mode=1
	//	CheckBox check_Amplitude,pos={38,511},size={108,14},title="Measure Amplitude"
	//	CheckBox check_Amplitude,value= 0,mode=1
	//	CheckBox check_Area,pos={159,511},size={84,14},title="Measure Area"
	//	CheckBox check_Area,value= 0,mode=1
	//	CheckBox check_SynAsyn,pos={253,511},size={154,14},title="Calculate Syn&Asyn Release"
	//	CheckBox check_SynAsyn,value= 0,mode=1
	//	CheckBox check_Minis,pos={413,511},size={46,14},title="MINIs",value= 0,mode=1
end

Function VersionPopup(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr			// contents of current popup item as string
	popNum=0
	popStr="Pulse;PatchMaster"
End


Window Panel_NeurignacioBrowser() : Panel
	ButtonProc_Folder("null")
	string/G exp_group=""
	string/G exp_name=""


	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(10,10,1000,760) as "PULSE Browser"
	SetDrawLayer UserBack
	SetDrawEnv textxjust= 1,textyjust= 1
	DrawText 110,94,"Group"
	SetDrawEnv textxjust= 1,textyjust= 1
	DrawText 110,142,"Serie"
	SetDrawEnv textxjust= 1,textyjust= 1
	DrawText 84,47,"Filename"
	SetDrawEnv textxjust= 1,textyjust= 1
	DrawText 216,207,"Protocol"
	SetDrawEnv textxjust= 1,textyjust= 1
	DrawText 495,20,"Sweep"
	DrawText 22,240,"Type:"
	Button button_folder,pos={1,2},size={50,20},proc=ButtonProc_Folder,title="Folder",help={"Load folder containing \".dat\" experiment files"}
	TitleBox title_folder,pos={52,2},size={301,21},help={"Current working folder"},fStyle=1,variable= folderstr
	ValDisplay valdisp_NumDATfiles,pos={150,40},size={38,15},title="of",help={"Total Number of Files in folder"},frame=0,limits={0,0,0},barmisc={0,1000},bodyWidth= 25,value= #"ItemsInlist(DATfiles)"
	ValDisplay valdisp_IndexDAT,pos={115,40},size={25,15},help={"Current number of file"},frame=0,limits={0,0,0},barmisc={0,1000},bodyWidth= 25,value= #"index_Dat+1"
	SetVariable setvar_protocolstr,pos={176,217},size={80,16},title=" ",help={"Name of the protocol (editable)"},value= protocolstr,bodyWidth= 80
	SetVariable setvar_SweepTot,pos={491,32},size={41,16},title="of ",help={"Total Number of Sweeps"},frame=0,limits={-inf,inf,0},value= SweepTot,noedit= 1,bodyWidth= 25
	SetVariable setvar_SweepCurrent,pos={462,32},size={25,16},title=" ",help={"Current Sweep"},frame=0,limits={-inf,inf,0},value= SweepCurrent,noedit= 1,bodyWidth= 25
	Button button_GroupNext,pos={152,102},size={23,23},proc=ButtonProc_TreeArrows,title="\\JC\\f01->",help={"Next Group"}
	Button button_GroupPrevious,pos={40,102},size={23,23},proc=ButtonProc_TreeArrows,title="\\JC\\f01<-",help={"Previous group"}
	Button button_SerieNext,pos={152,149},size={23,23},proc=ButtonProc_TreeArrows,title="\\JC\\f01->",help={"Next Serie"}
	Button button_SeriePrevious,pos={40,149},size={23,23},proc=ButtonProc_TreeArrows,title="\\JC\\f01<-",help={"Previous Serie"}
	Button button_SweepNext,pos={520,29},size={20,20},proc=ButtonProc_TreeArrows,title="\\JC\\f01->",help={"Next Sweep"}
	Button button_SweepPrevious,pos={432,29},size={20,20},proc=ButtonProc_TreeArrows,title="\\JC\\f01<-",help={"Previous Sweep"}
	Button button_Add,pos={190,110},size={50,50},proc=ButtonProc_AddExperiment,title="Add",help={"Add displayed Serie to the table"},fStyle=1,fColor=(16384,28160,65280)
	PopupMenu popup_Group,pos={65,102},size={86,24},help={"Current Group"},mode=1,bodyWidth= 86,value= #"GroupPopList"
	PopupMenu popup_Series,pos={65,149},size={86,24},proc=PopMenuProc_TreePopUp,help={"Current Serie"},mode=1,bodyWidth= 86,value= #"SeriePopList"
	TitleBox popup_FileName,pos={45,57},size={181,24},proc=PopMenuProc_FileName,help={"Current Experiment File"},mode=1,frame=5,fstyle=1,variable=DATfilename
	Button button_FilePrevious,pos={16,57},size={23,23},proc=ButtonProc_FileArrows,title="\\JC\\f01<-",help={"Previous experiment file"}
	Button button_FileNext,pos={221,57},size={23,23},proc=ButtonProc_FileArrows,title="\\JC\\f01->",help={"Next experiment file"}
	Button button_ZoomOut,pos={636,12},size={61,37},proc=ButtonProc_ZoomOUT,title="Reset",help={"Autoscale Zoom"}
	Button button_AllSweeps,pos={556,29},size={65,20},proc=ButtonProc_TreeArrows,title="Show All",help={"Display all the Sweeps"}
	PopupMenu popup_type,pos={64,220},size={86,24},proc=PopMenuProc_Type,title=" ",help={"Current type of neuron"},mode=1,bodyWidth= 70,value= #"\"EPSC;IPSC;?\""
	PopupMenu popup_ExpGroup,pos={64,195},size={86,24},help={"Current Experimental Condition"},mode=2,bodyWidth= 79,value= #"Exp_Group", mode=1
	Button button_AddExpGroup,pos={12,196},size={50,23},proc=ButtonProc_ExpGroup,title="Group",help={"New experimental condition will be created"}
	TitleBox title_Note,pos={7,248},help={"Information from the experiment"},labelBack=(65280,65280,48896),fStyle=0,fsize=11,variable=notestr
	GroupBox group_BrowseCommands,pos={7,31},size={251,154}
	GroupBox group_DisplayCommands,pos={425,2},size={277,56}
	GroupBox group_TableCommands,pos={7,190},size={252,58}
	
	DisplayWaveListInHost(wavelist("Pulse_*",";",""), "BrowseGraph", "Panel_NeurignacioBrowser")
	//	DisplayWaveListInHost(wavelist("Pulse_1_1_*Imon-2",";",""), "BrowseGraph", "Panel_NeurignacioBrowser")

EndMacro

// ------------------------------- FUNCTIONS ---------------------------------


//ButtonProc_SelAll("button_SelAll")
// Initial Values for High Train Analysis
//	TabProc_AnalysisTools("Tab_AnalysisTools",0)
//	Cursor/C=(65535,0,0)/H=1/S=1/L=1 A,$namewave,0.0005
//	Cursor/C=(65535,33232,0)/H=1/S=1/L=1 B,$namewave,0.0015
//	SetAxis bottom 0.00,0.002
//	AppendToGraph sucroseinterval
//End


function ListToWave(listin, namewave)
	string listin
	wave/T namewave
	variable num_items
	variable i=0
	
	num_items=ItemsInList(listin)
	Redimension/N=(num_items) namewave
	
	do
		if (cmpstr(listin,"")==0)
			Abort ("List contains no items")
		else
			namewave[i]=StringfromList(i,listin)
		endif
		i += 1
	while (i<=num_items-1)
end

function/S EnumerateItems(listin)
	string listin
	string listout
	string item
	variable num_items, i=0
	
	listout=""
	
	do
		item=StringfromList(0,listin)
		listin=RemovefromLIst(item,listin)
		listout += item+";"
	while (strlen(item)!=0)
	return listout
end

function/S EnumerateItemsfromWave(wavein)
	wave/T wavein
	string listout
	variable n,i=0
	
	n=numpnts(wavein)
	listout=""
	do
		if (strsearch(listout,wavein(i),0)<0)
			listout += wavein(i) + ";"
		endif
		i += 1
	while (i<=n)
	return listout
end

function CreateGroupWave(wavein)
	wave/T wavein
	WAVE/T group
	variable i=0
	
	do
		if (strsearch(wavein(i),"S25b",0)>=0)
			group[i]="S25b"
		endif
		if (strsearch(wavein(i),"WT",0)>=0)
			group[i]="WT"
		endif
		if (strsearch(wavein(i),"GFP",0)>=0)
			group[i]="GFP"
		endif
		i += 1
	while (i<=111)
end

proc SelectExperiments()
	string listout
	string groupcriteria, typecriteria, culturecriteria, protocolcriteria
	variable match,i,j,n,n_protocol=0
	string item, strtemp
	
	Setdatafolder root:
	listout=""
	// Create list of items selected from 'group'
	groupcriteria=""
	n=numpnts(groupsw)
	i=0
	do
		if (groupsw[i]>=48)
			groupcriteria += groupwave[i]+";"
		endif
		i+=1
	while (i<=n-1)
	
	// Create list of items selected from 'type'
	typecriteria=""
	n=numpnts(typesw)
	i=0
	do
		if (typesw[i]>=48)
			typecriteria += typewave[i]+";"
		endif
		i+=1
	while (i<=n-1)
	
	// Create list of items selected from 'Culture'
	culturecriteria=""
	n=numpnts(culturesw)
	i=0
	do
		if (culturesw[i]>=48)
			culturecriteria += culturewave[i]+";"
		endif
		i +=1
	while (i<=n-1)
	
	// Create list of items selected from 'protocol'
	protocolcriteria=""
	n=numpnts(protocolsw)
	i=0
	do
		if (protocolsw[i]>=48)
			protocolcriteria += protocolwave[i]+";"
		endif
		i +=1
	while (i<=n-1)
	n_protocol=ItemsInList(protocolcriteria)
	
	SetDataFolder root:Data
	n=numpnts(name)
	//Check if experiment matches with criteria
	i=0
	do
		if ((strsearch(groupcriteria,group[i],0)>=0) && (strsearch(typecriteria,type[i],0)>=0) && strsearch(culturecriteria, folder[i],0)>=0))
			match=1
		else
			match=0
		endif
		print i
		if (match==1) //name(i) matched grop and type
			j=0
			do
				item=StringFromList(j,protocolcriteria)
				strtemp=$item(i)
				if (cmpstr(strtemp,"")!=0)
					listout += name[i]+suffix[i] + ";"
				endif
				j+=1
			while (j<=n_protocol-1)
		endif
		i +=1
	while (i<=n-1)
	SetDataFolder root:
	if (strlen(listout)<=0)
		experimentwave[]=""
		Abort ("No Experiments were found.\rPossibly no experiment satisfies criteria.")
	else
		ListTowave(listout,experimentwave)
	endif
end

proc CalcRGB(red,blue,green)
	variable red,blue,green
	
	printf "%g,%g,%g",red*65535/255,blue*65535/255,green*65535/255
end

Function UpdateButtonProc(ctrlName) : ButtonControl
	String ctrlName
	variable n
	wave experimentwave, experimentsw
	
	execute "Selectexperiments()"
	n=numpnts(experimentwave)
	//Redimension/N=0 experimentsw
	Redimension/N=(n) experimentsw
	experimentsw=32
	listbox experimentbox listwave=experimentwave,selwave=experimentsw,mode=4
End

function FindStringValue(str,w)
	string str
	wave/T w
	variable i,n
	variable p=-1
	
	n=numpnts(w)-1
	i=0
	do
		if (cmpstr(str,ReplaceString("¯",w[i],"O"))==0)
			p=i
			break
		endif
		i +=1
	while (i<=n)
	return p
end


proc LoadExperiments(ctrlName) : ButtonControl
	String ctrlName
	
	string protocolcriteria, item, protocoltemp
	string nametemp, filenametemp, strtemp, wavenumtemp
	variable groupnum, seriesnum=1, wavenum
	variable n_exp,more,i,j,n,n_protocol=0
	string pathname // Name of the path
	string loaded_experiments
	variable s, time0
	
	NewDataFolder/O root:OrigData
	SetDataFolder root:
	time0=datetime
	pathname=root:Data:S_path
	groupnum=1 //Only 1st group are considered
	
	// Create list of items selected from 'protocol'
	protocolcriteria=""
	n=numpnts(protocolsw)
	i=0
	do
		if (protocolsw[i]>=48)
			protocolcriteria += protocolwave[i]+";"
		endif
		i +=1
	while (i<=n-1)
	n_protocol=ItemsInList(protocolcriteria)
	
	n=numpnts(experimentwave)
	i=0
	do
		if (experimentsw[i]>=48)
			nametemp=experimentwave[i]
			//			if ((cmpstr(nametemp,experimentwave[i-1])==0) && (i>1))
			//				more=1
			//			else
			//				more=0
			//			endif
			//			n_exp=findStringValue(nametemp,name)+more
			SetDataFolder root:Data
			n_exp=findexperiment(nametemp)
			j=0
			do
				item=StringFromList(j,protocolcriteria)
				protocoltemp=$item(n_exp)
				//				seriesnum=trunc(str2num(protocoltemp)) // Here it decides which sweep to get
				if (cmpstr(protocoltemp,"")!=0)
					s=ItemsInList(protocoltemp)
					do
						nametemp=name[n_exp]//					nametemp=experimentwave[i]
						s -= 1
						seriesnum=str2num(StringFromList(s,protocoltemp,";"))
						if (seriesnum!=0)
							//						filenametemp=pathname+folder[n_exp]+":"+nametemp+".dat"	//":"
							filenametemp=pathname+":"+nametemp+".dat"	//":"
							//						wave_name=
							//						if ((cmpstr(nametemp,experimentwave[i+1])==0) && (i<n))
							//							nametemp=nametemp+"a"
							//						endif
							//						if ((cmpstr(nametemp,experimentwave[i-1])==0) && (i>1))
							//							nametemp=nametemp+"b"
							//						endif
							nametemp=nametemp+suffix[n_exp]
							SetDataFolder root:OrigData
							print filenametemp
							wavenumtemp=num2str(wavenum)
							//	LoadPulse/A=(groupnum)/B=(seriesnum)/N=$(nametemp+"@"+item) filenametemp
							ControlInfo popup0
							//	if (cmpstr(S_Value,"Pulse")==0)
							LoadPM/A=(groupnum)/B=(seriesnum)/N=$("x"+wavenumtemp+item) filenametemp
							//	elseif (cmpstr(S_Value,"PatchMaster")==0)
							//		LoadPM/A=(groupnum)/B=(seriesnum)/N=$("x"+wavenumtemp+item) filenametemp
							//	endif

							loaded_experiments += "x"+wavenumtemp+item+";"
							wavenum += 1

							SetDataFolder root:Data
						endif
					while (s>0)
				endif
				j+=1
//			while (j<n_protocol-1)
			while (j<n_protocol)
			SetDataFolder root:
			List_Experiments += nametemp+";"//AddListItem(List_Experiments,nametemp) //+"@"+item+"_"+num2str(groupnum)+"_"+num2str(seriesnum)) //Generate a list of experiments loaded
			//			print "List_experiments =",  List_Experiments
			//			print findexperiment(nametemp),nametemp,"was loaded successfully"
		endif
		i+=1
	while (i<=n-1)
	//	list_experiments=removelistitem(0,list_Experiments) // Remove first empty "" item
	print "List_experiments =",  List_Experiments
	print ItemsInList(list_experiments),"experiments loaded in", datetime-time0, "secs"
End


function ConttoEpis(w, namewave,freq,x_first)
	wave w
	string namewave
	variable freq,x_first
	variable p_first
	variable segmentlength, nSegments
	variable bp=50 //num points before stimulus
	
	p_first=x2pnt(w,x_first)
	segmentlength=x2pnt(w,1/freq)
	//nSegments=round((numpnts(w)-(p_first-bp)/segmentlength)
	duplicate w,waveforconttoepis
end

function EpisToCont(list, namewave)
	string list,namewave
	variable i,n,points, p0,p1
	string item
	
	n=ItemsInList(list)-1
	item=StringfromList(i,list)
	Duplicate/O $item,$namewave
	points=numpnts($namewave)
	wave w=$namewave
	i=1
	do
		item=StringfromList(i,list)
		wave w_item=$item
		p0=points
		points +=numpnts(w_item)
		Redimension/N=(points) w
		w[p0,points-1]=w_item[p-p0]
		DoUpdate
		i += 1
	while (i<=n)
end


function FindRoot(name, separator) //equivalent to strsearch
	string name, separator
	variable num_car,i
	
	num_car=strlen(name)
	i=num_car
	do
		i -=1
	while ((i>0) && cmpstr(name[i],separator)!=0)
	return i-1
end

function ReviewWavesInList(list)
	string list
	variable num_items,i,j
	string item, namewave
	string graphname
	
	num_items=ItemsInList(List)
	i=1
	do
		item=stringfromlist(i,list)
		graphname="graphtemp"+num2str(i)
		Dowindow/C $graphname
		display
		j=1
		do	
			namewave=item+"_"+num2str(j)
			if (waveexists($namewave)==0)
				break
			endif
			AppendtoGraph $namewave
			AutopositionWindow/E
			j +=1
		while (j>1)
		i +=1
	while (i<num_items)
	Make/O/N=(num_items) review_wave // Cointains if wave is selected or no (0)
	review_wave=1 // All are selected by default
end


Function DisplayWaveList(list)
	String list // A semicolon-separated list.
	String theWave
	Variable index=0
	variable pos
	string temp
	
	do
		// Get the next wave name
		theWave = StringFromList(index, list)
		pos=strsearch(theWave,"@",0)-1
		if (pos<0)
			pos=strlen(theWave)-1
		endif
		//	if (strsearch(theWave[0,pos],"_",0)-1>0)
		//		pos=strsearch(theWave[0,pos],"_",0)-1
		//	endif
		if (strlen(theWave) == 0)
			break // Ran out of waves
		endif
		if (index == 0) // Is this the first wave?
			Display/K=1/W=(2.25,38,954,425) $theWave
			//		temp="Dowindow/C "+ReplaceString("Ø",theWave[0,pos],"O") //Changes 'Ø' for a compatible graph name
			Dowindow/C theWave
			//		Execute temp
		else
			AppendToGraph $theWave
		endif

		index += 1
	while (1) // Loop until break above
End

Function RenameAllWaveNamesPPT(waveFolder)
	String waveFolder
	String objName, objNameNew
	Variable index = 0, wavecount, strStart=7, strEnd, strLength, flag=0, temp_pos1, temp_pos2  
  
	SetDataFolder root:$waveFolder
  
	wavecount = CountObjects("", 1)
	do
		objName = GetIndexedObjName("", 1, index)
		if (strlen(objName) == 0)
			break
		endif
		strLength = strlen(objName)
		strEnd = strLength - 1 //IGOR indexes strings starting from 0!
   
		flag=0  
		do
			if (cmpstr(objName[strEnd], "_")==0) //cmpstr returns 0 if strings are equal
				flag=1
			else
				strEnd-=1
			endif
		while((flag==0) && (strEnd>strStart))
   
		objNameNew = "pm"+objName[strStart, strEnd+1]
		temp_pos1 = Strsearch(objNameNew, "Leak", 0)
		temp_pos2 = temp_pos1
		do
			temp_pos2-=1
		while((temp_pos2>0) &&  (cmpstr(objNameNew[temp_pos2], "_")!=0))
		objNameNew = objNameNew[0,temp_pos2-1] + objNameNew[temp_pos1, strlen(objNameNew)-1]
		wave w = WaveRefIndexed("", index ,4)
		make/O $objNameNew=NaN
		wave waveOutput = $objNameNew
   
		Printf "Designated name for wave: %s\r", objNameNew
		duplicate/O w waveOutput
		//   MoveWave (blush)objNameNew,root: 
		index += 1
	while(index<wavecount)
	Print wavecount
	SetDataFolder root:
End

Function ButtonProc_SelAll(ctrlName) : ButtonControl
	String ctrlName
	wave review_wave
	NVAR tracenum
	variable i,nmax
	
	nmax=numpnts(review_wave)
	i=0
	do
		review_wave[i]=1
		ModifyGraph lstyle[i]=0, rgb[i]=(1,65535,33232), lsize[i]=1 //blue-green
		i +=1
	while (i<=nmax-1)
	ModifyGraph/Z lstyle[tracenum]=0, rgb[tracenum]=(0,0,65535), lsize[tracenum]=3	//blue
	review_wave=1
	CheckBox check_selected value=1
End

Function ButtonProc_SelNone(ctrlName) : ButtonControl
	String ctrlName
	wave review_wave
	NVAR tracenum
	variable i,nmax

	nmax=numpnts(review_wave)
	i=0
	do
		review_wave[i]=1
		ModifyGraph lstyle[i]=0, rgb[i]=(51664,44236,58982), lsize[i]=1 //blue-green
		i +=1
	while (i<=nmax-1)
	ModifyGraph/Z lstyle[tracenum]=0, rgb[tracenum]=(13112,0,26214), lsize[tracenum]=3	//blue
	review_wave=0
	CheckBox check_selected value=0
End



Function ListBoxProc_listbox(ctrlName,row,col,event) : ListBoxControl
	String ctrlName
	Variable row
	Variable col
	Variable event	//1=mouse down, 2=up, 3=dbl click, 4=cell select with mouse or keys
	//5=cell select with shift key, 6=begin edit, 7=end

	string selwave
	
	if (event==4 || event==5)
		selwave=ctrlname[0,strsearch(ctrlname,"box",0)-1]+"sw"
		wave sw=$selwave
		sw[row]=sw[row] -1
	endif
	return 0
End

Function ButtonProc_SelAllExperiments(ctrlName) : ButtonControl
	String ctrlName
	wave experimentsw
	experimentsw[]=48
End

Function ButtonProc_SelNoneExperiments(ctrlName) : ButtonControl
	String ctrlName
	wave experimentsw
	experimentsw[]=32
End

Function ButtonProc_ResetListBoxes(ctrlName) : ButtonControl
	String ctrlName
	wave protocolsw,groupsw,typesw, culturesw, experimentsw
	
	protocolsw=32
	groupsw=32
	typesw=32
	culturesw=32
	experimentsw=32

End


function FindExperiment(s) 
	String s //'s' is the name of a experiment wave
	variable more,i,n
	string oldDF
	
	oldDF=GetDataFolder(1)
	SetDataFolder root:Data
	s=ReplaceString("Ø", s, "O")
	wave name
	//	more = 0
	i=strsearch(s,"@",0)
	if (i<=0)
		i=strlen(s)
	endif
	//if (strsearch(s[0,i+1],"_",0)>0)
	//	i=strsearch(s[0,i+1],"_",0)
	//endif

	do
		i -= 1
		n=FindStringValue(s[0,i],name)
		//		if (cmpstr(s[i,i+1],"b@")==0) // correct 'b' ending
		//			more =1
		//		endif
		more=char2num(Upperstr(s[i+1]))-65
		if ((more<0) || (numtype(more)!=0) || (more>=25))
			more=0
		endif
	while (n<0 && i>=0)
	n += more
	SetDataFolder oldDF
	return n
end

Function ButtonProc_LoadINFO(ctrlName) : ButtonControl
	String ctrlName
	NewDataFolder/O/S root:Data
	Execute "LoadWave/J/W/O/K=2"
	SetDataFolder root:	
	Initialize_Variables()
	Accessories()
End


Function ButtonProc_Folder(ctrlName) : ButtonControl
	String ctrlName
	NewPath/O/Q/Z/M="Select Folder with HEKA experiment files" Path_Experiment
	if (V_Flag!=0)
		abort
	endif
	PathInfo Path_experiment
	string/G folderstr=S_path
	variable/G index_DAT=0
	string/G DATfiles=indexedfile(Path_experiment,-1,".dat") //List of the ".dat" files in folder
	string/G DATfilename=indexedfile(Path_experiment,index_DAT,".dat") //filename of the first ".dat" of the folder
	string version
	Prompt version, "Format:",popup "Pulse;PatchMaster"
	DoPrompt "Please specify Data format.", version
	string/G gVersion=version
	// Choose which amplifier
	if (cmpstr(gVersion,"PatchMaster")==0)
		string amplifier
		Prompt amplifier, "Format:",popup "EPC9;EPC9(old);EPC10"
		DoPrompt "Please specify amplifier.", amplifier
		string/G gAmplifier=amplifier
	endif
	//
	RefreshFirstFile(DATfilename)
End

function/S fLoadPulse(groupnum, seriesnum, sweepnum, basename, filenamestr)
	variable groupnum, seriesnum, sweepnum
	string basename, filenamestr
	string cmd_str=""
	SVAR gVersion
	
	if (groupnum>0)
		cmd_str += "/A="+num2str(groupnum)
	endif
	if (seriesnum>0)
		cmd_str += "/B="+num2str(seriesnum)
	endif
	if (sweepnum>0)
		cmd_str +="/C="+num2str(sweepnum)
	endif
	
	//	ControlInfo popup0
	if (cmpstr(gVersion,"Pulse")==0)
		Execute "LoadPulse/O"+cmd_str+"/N="+PossiblyQuoteName(basename)+" \""+filenamestr+"\""
	elseif (cmpstr(gVersion,"PatchMaster")==0)
		Execute "LoadPM/O"+cmd_str+"/N="+PossiblyQuoteName(basename)+" \""+filenamestr+"\""
	endif
	
end

function GetPulseNote(w, basename) //w is a wave obtained by LoadPulse
	wave w
	string basename

	string/G notestr=note(w)
	//print notestr
	variable n_lines=itemsinlist(notestr,"\r")-1
	Make/O/T/N=(n_lines+1,2) $(basename)
	wave/T w_note=$(basename)
	w_note=""
	variable i_line=0
	do
		string linestr=StringfromList(i_line,notestr,"\r")
		variable n_items=ItemsInList(linestr,"\t")-1
		w_note[i_line][1]=StringfromList(0,linestr,"\t")
		if (n_items>0)
			w_note[i_line][0]=Stringfromlist(n_items,linestr,"\t")
		endif
		i_line += 1
	while (i_line<=n_lines)
end

Function DisplayWaveListInHost(list, graphname, hostname)
	String list // A semicolon-separated list.
	string graphname, hostname
	string graphname2, newname
	String theWave, theWave2
	Variable index=0, double=0
	SVAR gVersion
	
	do
		if (cmpstr(gVersion,"Pulse")==0)
			// Get the next wave name
			theWave = StringFromList(index, list)
			if (strlen(theWave) == 0)
				break // Ran out of waves
			endif
			if (index == 0) // Is this the first wave?
				if (FindListItem(graphname,ChildWindowList(hostname))>=0)
					KillWindow $(hostname+"#"+graphname)
				endif
				Display/W=(264,60,1280,555)/HOST=$hostname/N=$graphname/K=1/W=(2.25,38,954,425) $theWave
			else
				SetActiveSubWindow $(hostname+"#"+graphname)
				AppendToGraph $theWave
			endif
	
		elseif (cmpstr(gVersion,"PatchMaster")==0)
			// Get the next wave name
			theWave = StringFromList(index, list)
			if (strlen(theWave) == 0)
				break // Ran out of waves
			endif
			//			newname = ReplaceString("-",theWave,"_")
			//			rename $theWave, $newname
			//			theWave=newname
			// double = 1
			// graphname2=graphname
			// graphname2=graphname2+"2"
			// theWave2=theWave
			// if (StringMatch(theWave2, "*1-Imon-1"))
			//	theWave2=RemoveEnding(theWave2,"1-Imon-1")
			//	theWave2=theWave2+"2-Imon-2"
			// else
			//	theWave2=RemoveEnding(theWave2,"1-Vmon-1")
			//	theWave2=theWave2+"2-Vmon-2"
			//Endif
			
			//			theWave2=theWave2+"2-Imon-2"
			//			newname = ReplaceString("-",theWave2,"_")
			//			rename $theWave2, $newname
			//			theWave2=newname
			//			endif
						if (index == 0) // Is this the first wave?
							if (FindListItem(graphname,ChildWindowList(hostname))>=0)
								KillWindow $(hostname+"#"+graphname)
								// KillWindow $(hostname+"#"+graphname2)
							endif
			Display/W=(264,60,1280,275)/HOST=$hostname/N=$graphname/K=1/W=(2.25,38,954,210) $theWave
			// Display/W=(264,280,1280,555)/HOST=$hostname/N=$graphname2/K=1/W=(2.25,253,954,425) $theWave2
						else
							SetActiveSubWindow $(hostname+"#"+graphname)
							AppendToGraph $theWave						
							// SetActiveSubWindow $(hostname+"#"+graphname2)
							// AppendToGraph $theWave2
						endif
		endif
		index += 1
	while (1) // Loop until break above	
End


Function PopMenuProc_TreePopUp(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR groupcurrent, SeriesCurrent, SweepCurrent
	ControlInfo PopUp_Group
	GroupCurrent=V_Value
	ControlInfo PopUp_Series
	SeriesCurrent=V_Value
	SweepCurrent=1
	RefreshNewSweeps(GroupCurrent, SeriesCurrent, SweepCurrent)
End

function KillAllWaves(namewave)
	string namewave
	string list, strtemp
	variable i,n
	
	list=listwaves(namewave)
	i=0
	n=Itemsinlist(list)-1
	do
		Killwaves/Z $StringfromList(i,list)
		i += 1
	while (i<=n)
end

function/S ListWaves(namestr)
	string namestr
	string strtemp, listout
	strtemp="*"+namestr+"*"
	listout=Wavelist(strtemp,";","")
	print "listout =", listout
	return listout
end

Function ButtonProc_TreeArrows(ctrlName) : ButtonControl
	String ctrlName
	NVAR GroupCurrent, SeriesCurrent, SweepCurrent
	NVar GroupTot, SeriesTot, SweepTot
	variable DisplayNewGraph=0 //Do I need to display the new graph? 0=No, 1=Yes

	if ((cmpstr(ctrlName,"Button_GroupPrevious")==0) && (GroupCurrent>1))
		GroupCurrent -=1
		SweepCurrent=0
		PopUpMenu PopUp_Group mode=GroupCurrent
		DisplayNewGraph=1
	elseif ((cmpstr(ctrlName,"Button_GroupNext")==0) && (GroupCurrent<GroupTot))
		GroupCurrent +=1
		SweepCurrent=0
		PopUpMenu PopUp_Group mode=GroupCurrent
		DisplayNewGraph=1
	elseif ((cmpstr(ctrlName,"Button_SeriePrevious")==0) && (SeriesCurrent>1))
		SeriesCurrent -=1
		SweepCurrent=0
		PopUpMenu PopUp_Series mode=SeriesCurrent
		DisplayNewGraph=1
	elseif ((cmpstr(ctrlName,"Button_SerieNext")==0) && (SeriesCurrent<SeriesTot))
		SeriesCurrent +=1
		SweepCurrent=0
		PopUpMenu PopUp_Series mode=SeriesCurrent
		DisplayNewGraph=1
	elseif ((cmpstr(ctrlName,"Button_SweepPrevious")==0) && (SweepCurrent>1))
		SweepCurrent -=1
		//		PopUpMenu PopUp_Sweep mode=SweepCurrent
		DisplayNewGraph=1
	elseif ((cmpstr(ctrlName,"Button_SweepNext")==0) && (SweepCurrent<SweepTot))
		SweepCurrent +=1
		//		PopUpMenu PopUp_Sweep mode=SweepCurrent
		DisplayNewGraph=1
	elseif (cmpstr(ctrlName,"Button_AllSweeps")==0)
		SweepCurrent=0
		//		PopUpMenu PopUp_Sweep mode=SweepCurrent
		DisplayNewGraph=1
	endif
	if (DisplayNewGraph==1)
		RefreshNewSweeps(GroupCurrent, SeriesCurrent, SweepCurrent)
	endif
End

Function PopMenuProc_FileName(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	string/G DATfilename=PopStr
	variable/G index_DAT=popNum
	RefreshFirstFile(DATfilename)
End

Function ButtonProc_FileArrows(ctrlName) : ButtonControl
	String ctrlName
	SVAR DATfiles
	NVAR index_DAT
	variable numfiles=ItemsInList(DATfiles), indextemp
	variable DisplayNewGraph=0
	string namestr

	if ((cmpstr(ctrlName,"Button_FilePrevious")==0) && (index_DAT>0))
		indextemp=index_DAT-1
		namestr=StringFromList(indextemp, DATfiles)
		if (strlen(namestr)==0)
			DoAlert 0,"Ran out of waves."
			DisplayNewGraph=0
		else
			index_DAT -=1
			DisplayNewGraph=1
		endif
	elseif ((cmpstr(ctrlName,"Button_FileNext")==0) && (index_DAT<numfiles))
		indextemp=index_DAT+1
		namestr=StringFromList(indextemp, DATfiles)
		if (strlen(namestr)==0)
			DoAlert 0,"Ran out of waves."
			DisplayNewGraph=0
		else
			index_DAT +=1
			DisplayNewGraph=1
		endif
	endif
	
	if (DisplayNewGraph==1)
		SVAR DATfilename
		DATfilename=StringFromList(index_DAT, DATfiles)
		//		ControlUpdate/A
		RefreshFirstFile(DATfilename)
	endif
End


Function ButtonProc_ZoomOUT(ctrlName) : ButtonControl
	String ctrlName
	Setactivesubwindow Panel_NeurignacioBrowser#BrowseGraph
	SetAxis/A left
	SetAxis/A bottom
End

Function ButtonProc_AddExperiment(ctrlName) : ButtonControl
	String ctrlName
	NVAR GroupCurrent, SeriesCurrent
	SVAR folderstr, DATfilename, protocolstr
	ControlInfo PopUp_expGroup
	string expgroupstr=S_Value
	ControlInfo PopUp_type
	string typestr=S_Value
	//	ControlInfo check_NewExperiment
	//	variable NewExperiment=1-V_Value //1: new entrance will be created for this filename
	
	
	if (WaveExists(folder)==0)
		Make/T/N=0 folder
	endif
	if (WaveExists(name)==0)
		Make/T/N=0 name
	endif
	if (WaveExists(suffix)==0)
		Make/T/N=0 suffix
	endif
	if (WaveExists(group)==0)
		Make/T/N=0 group
	endif
	if (WaveExists(type)==0)
		Make/T/N=0 type
	endif
	if (WaveExists($(protocolstr))==0)
		if (stringmatch(protocolstr, "*;"))
			protocolstr=RemoveEnding(protocolstr)
		endif
		Make/T/N=(numpnts(name)) $(protocolstr)
		SVAR/Z protocol_list		// Added /Z to the SVAR to prevent an error
		if (SVAR_exists(protocol_list)!=1) // Protocol_list does NOT exist, so I create it
			string/G protocol_list=""
		endif
		protocol_list +=protocolstr+";"
	endif
	wave/T w_protocol=$(protocolstr)
	
	if (FindListItem("DataTable", ChildWindowList("Panel_NeurignacioBrowser"))<0)
		edit/HOST=Panel_NeurignacioBrowser/N=DataTable/W=(0,555,1280,1024) folder, name, suffix, group, type
		Button button_save,pos={220,280},size={50,50},proc=ButtonProc_SaveTable,title="Save",help={"Save table to file"},fStyle=1,fColor=(16384,28160,65280)	//Added by Jakob to allow saving table to file
	endif
	CheckDisplayed/W=Panel_NeurignacioBrowser#DataTable w_protocol
	if (V_Flag==0)
		AppendtoTable/W=Panel_NeurignacioBrowser#DataTable w_protocol 
	endif
	
	//	wave w_folder=folder
	//	wave w_name=name
	//	wave w_suffix=suffix
	//	wave w_group=group
	//	wave w_type=type
	
	string namestr=DATfilename[0,strlen(DATfilename)-5] //Removes final ".dat"
	variable n=numpnts(name)-1

	if  ((cmpstr(namestr, name[n])==0) && (n>=0))
		Redimension/N=(numpnts(name)) w_protocol
		w_protocol[n][0] += num2str(SeriesCurrent)+";"
		//		w_protocol[n][1] += num2str(GroupCurrent)+";"
	else
		if (cmpstr(namestr, name[n])==0)
			if (cmpstr("",suffix[n])==0)
				AddTextWaveItem("B", suffix)
				suffix[n]="A"
			else
				AddTextWaveItem(num2char(char2num(suffix[n])+1),suffix) //C,D,E,F.....
			endif
		else
			AddTextWaveItem("",suffix)
		endif
		AddTextWaveItemInit(folderstr, folder)
		AddTextWaveItem(namestr, name)
		AddTextWaveItem(expgroupstr, group)
		AddTextWaveItem(typestr, type)
		AddTextWaveItem(num2str(SeriesCurrent)+";", w_protocol)
		//		CheckBox check_NewExperiment value=1
	endif
	string/G exp_name=name[n+1]+suffix[n+1]
	//else
	//	beep //this serie was already added
	//endif	
	
End



Function ButtonProc_SaveTable(ctrlName) : ButtonControl			//Added by Jakob to save Table easily
String ctrlName
SVAR protocol_list

variable i, n
string Savestring, newstr

Savestring="folder;name;suffix;group;type;"
Savestring+=	protocol_list
Save/J/B/M="\r\n"/W/F/I Savestring as "DataList.txt"

End

function AddTextWaveItemInit(itemStr, w)
	string ItemStr
	wave/T w
	variable n=numpnts(w)
	Redimension/N=(n+1) w
	w[n]=Itemstr
end

function AddTextWaveItem(itemStr, w)
	string ItemStr
	wave/T w
	variable n=numpnts(folder)
	Redimension/N=(n) w
	w[n]=Itemstr
end
	

Function PopMenuProc_Type(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	String/G typestr=PopStr
End

Function ButtonProc_ExpGroup(ctrlName) : ButtonControl
	String ctrlName
	string/G exp_group
	string groupstr
	
	prompt groupstr, "Group: "
	DoPrompt "Add New Experiment Group", groupstr
	if (V_flag)
		return -1
	endif
	exp_group += groupstr+";"
	Popupmenu popup_expgroup mode=ItemsInList(exp_group)
End


function RefreshFirstFile(DATfilename)
	string DATfilename
	SVAR folderstr, gVersion, gAmplifier
	
	variable/G GroupCurrent=1
	variable/G SeriesCurrent=1
	variable/G SweepCurrent=1
	fLoadPulse(GroupCurrent, SeriesCurrent,0,"Pulse",folderstr+DATfilename) //Load Pulse ".dat"
	
	
	if (cmpstr(gVersion,"PatchMaster")==0)
		if (cmpstr(gAmplifier,"EPC9")==0)  // Decide which amplifier to use
			getpulsenote($"Pulse_1_1_1_1-CurrentIn", "NotePulse") //Obtain information from Pulse Note
		elseif  (cmpstr(gAmplifier,"EPC9(old)")==0)
			getpulsenote($"Pulse_1_1_1_1-I-mon", "NotePulse") //Obtain information from Pulse Note
		else
			print "going to get note..."
			getpulsenote($"Pulse_1_1_1_1-Imon-1", "NotePulse") //Obtain information from Pulse Note
		endif
	elseif (cmpstr(gVersion,"Pulse")==0)
		getpulsenote($"Pulse_1_1_1", "NotePulse") //Obtain information from Pulse Note
	endif
	
	
	wave/T wavenote=NotePulse
	if (cmpstr(gVersion,"Pulse")==0)
		string/G protocolstr=wavenote[12][0] //Stores name of the protocol for the Sweep
	elseif (cmpstr(gVersion,"PatchMaster")==0)
		string/G protocolstr=wavenote[13][0] //Stores name of the protocol for the Sweep
	endif
	if (stringmatch(protocolstr, "*;"))
		protocolstr=RemoveEnding(protocolstr)
	endif
	
	//Obtain Tree Limits from Pulse Note (groups, series, sweeps) and creates PopUp Lists
	string tempstr=wavenote[5][0]
	variable/G GroupTot=str2num(tempstr[strsearch(tempstr,"of ",0)+3,Inf])
	string/G GroupPopList=""
	variable i=1
	do
		GroupPopList += num2str(i)+" of "+num2str(GroupTot)+";"
		i +=1
	while (i<=GroupTot)

	tempstr=wavenote[6][0]
	variable/G SeriesTot=str2num(tempstr[strsearch(tempstr,"of ",0)+3,Inf])
	i=1
	string/G SeriePopList=""
	do
		SeriePopList += num2str(i)+" of "+num2str(SeriesTot)+";"
		i +=1
	while (i<=SeriesTot)
	
	tempstr=wavenote[7][0]
	variable/G SweepTot=str2num(tempstr[strsearch(tempstr,"of ",0)+3,strlen(tempstr)-1])
	i=1
	string/G SweepPopList=""
	do
		SweepPopList += num2str(i)+" of "+num2str(SweepTot)+";"
		i +=1
	while (i<=SweepTot)
	if (cmpstr(Winlist("*NeurignacioBrowser*",";","WIN:64"),"")!=0)
		PopUpMenu PopUp_Group mode=1
		PopUpMenu PopUp_Series mode=1
		//	PopUpMenu PopUp_Sweep mode=1
		DisplayWaveListInHost(wavelist("Pulse_1_1_*",";",""), "BrowseGraph", "Panel_NeurignacioBrowser")
	endif
End

function RefreshNewSweeps(GroupCurrent, SeriesCurrent, SweepCurrent)
	variable GroupCurrent, SeriesCurrent, SweepCurrent
	variable AllSweeps
	String theWave, StringOfWave
	if (SweepCurrent<=0)
		NVAR gSweepCurrent=SweepCurrent
		gSweepCurrent=1
		SweepCurrent=1
		AllSweeps=0
	else
		AllSweeps=SweepCurrent
	endif
	SVAR folderstr,Datfilename,gVersion,gAmplifier
	KillWindow Panel_NeurignacioBrowser#BrowseGraph
	//if (cmpstr(gVersion,"PatchMaster")==0)
	//	KillWindow Panel_NeurignacioBrowser#BrowseGraph2
	//endif
	KillAllWaves("Pulse_")
	fLoadPulse(GroupCurrent, SeriesCurrent,AllSweeps,"Pulse",folderstr+DATfilename) //Load Pulse ".dat"
	DisplayWaveListInHost(ListWaves("Pulse_"+num2str(groupcurrent)+"_"+num2str(seriescurrent)+"_"), "BrowseGraph", "Panel_NeurignacioBrowser")

	StringOfWave=ListWaves("Pulse_"+num2str(groupcurrent)+"_"+num2str(seriescurrent)+"_")
	//print "StringOfWave ",StringOfWave
	
	if (cmpstr(gVersion,"PatchMaster")==0)
		if (cmpstr(gAmplifier,"EPC9")==0) // Decide which amplifier to use
			getpulsenote($("Pulse_"+num2str(groupcurrent)+"_"+num2str(seriescurrent)+"_"+num2str(SweepCurrent)+"_1-CurrentIn"), "NotePulse") //Obtain information from Pulse Note
		elseif (cmpstr(gAmplifier,"EPC9(old)")==0) // Decide which amplifier to use
			getpulsenote($("Pulse_"+num2str(groupcurrent)+"_"+num2str(seriescurrent)+"_"+num2str(SweepCurrent)+"_1-I-mon"), "NotePulse") //Obtain information from Pulse Note
		else
			if(stringmatch(StringOfWave, "*Imon*")==1)
					getpulsenote($("Pulse_"+num2str(groupcurrent)+"_"+num2str(seriescurrent)+"_"+num2str(SweepCurrent)+"_1-Imon-1"), "NotePulse") //Obtain information from Pulse Note
			endif
			if(stringmatch(StringOfWave, "*Vmon*")==1)		//programmed by Jakob B. Sørensen on 8. July 2021 to allow loading of current clamp data
					getpulsenote($("Pulse_"+num2str(groupcurrent)+"_"+num2str(seriescurrent)+"_"+num2str(SweepCurrent)+"_1-Vmon-1"), "NotePulse") //Obtain information from Pulse Note
			endif
		endif
	elseif (cmpstr(gVersion,"Pulse")==0)
		getpulsenote($("Pulse_"+num2str(groupcurrent)+"_"+num2str(seriescurrent)+"_"+num2str(SweepCurrent)), "NotePulse") //Obtain information from Pulse Note
	endif

	wave/T wavenote=NotePulse
	if (cmpstr(gVersion,"Pulse")==0)
		string/G protocolstr=wavenote[12][0] //Stores name of the protocol for the Sweep
	elseif (cmpstr(gVersion,"PatchMaster")==0)
		string/G protocolstr=wavenote[13][0] //Stores name of the protocol for the Sweep
	endif
	if (stringmatch(protocolstr, "*;"))
		protocolstr=RemoveEnding(protocolstr)
	endif
	string tempstr=wavenote[7][0]
	variable/G SweepTot=str2num(tempstr[strsearch(tempstr,"of ",0)+3,strlen(tempstr)-1])

end
