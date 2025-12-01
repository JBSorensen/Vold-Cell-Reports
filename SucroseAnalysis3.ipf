#pragma rtGlobals=1		// Use modern global access method.
#include <FitODE>

Macro SucRate2(SucTrace, BeginP,EndP)
string SucTrace 
prompt SucTrace, "Select Evoke",popup,WaveList("*", ";", "")
variable BeginP=6, EndP=7
prompt BeginP, "Select beginning time of plateau"
prompt EndP, "Select beginning time of plateau"

string SucTracetemp=SucTrace+"t", SucTraceTempF=SucTrace+"tF", SucTraceTempFS=SucTrace+"tF_s", SucTraceTempPool=SucTrace+"Po", SucTraceTempBase=SucTrace+"B"
string cmdString, currentFolder
duplicate /O $SucTrace $SucTracetemp

Variable TimeZero, i=0, PeakF, MinT_F, HalfTimeB, HalfTimeA, HalfTime, SS_F, plateauCross, PoolSize

string HalfLine=SucTrace+"_A"
string HalflineT=SucTrace+"_B"

Make /O/N=2 $HalfLine, $HalfLineT

Wavestats /Q /R=(0,0.5) $SucTracetemp
$SucTraceTemp-=V_avg

Silent 1;

Smooth 30001, $SucTracetemp
duplicate /O $SucTraceTemp $SucTracetempF
currentFolder=GetDataFolder(1)
cmdString=currentFolder+SucTracetempF
print "CmdString =", cmdString
SlimWaves/U=10/N=s $cmdString
Smooth 25001, $SucTracetempFS
Killwaves $Suctracetemp, $SucTraceTempF

WaveStats /Q/R=(2,7) $SucTraceTempFS
minT_F=V_minloc
PeakF=V_min
print "minimum of  filtered trace =", minT_F, " is at ", PeakF

Wavestats /Q/R=(BeginP,EndP) $SucTraceTempFS
SS_F=V_avg
print "Steady level is = ", SS_F
i=x2pnt($SucTraceTempFS, minT_F)

if(SS_F>0)
	duplicate /O $SucTraceTempFS Diff2trace
	differentiate Diff2trace
	differentiate Diff2trace
	WaveStats /Q/R=(2,3.5) Diff2trace
	$SucTraceTempFS(V_minloc,inf)-=SS_F*(1-exp(-(x-V_minloc)/0.0005))
	KillWaves Diff2trace
	
	print "NB! Correcting for positive plateau!!!"
	
	WaveStats /Q/R=(2,7) $SucTraceTempFS
	minT_F=V_minloc
	PeakF=V_min
	print "minimum of  filtered trace =", minT_F, " is at ", PeakF

	Wavestats /Q/R=(BeginP,EndP) $SucTraceTempFS
	SS_F=V_avg
	print "Steady level is = ", SS_F
	i=x2pnt($SucTraceTempFS, minT_F)
endif

do
	i-=1
while($SucTraceTempFS[i]<SS_F)
plateauCross=pnt2x($SucTraceTempFS, i)
print "plateau Crossing = ", plateauCross

PoolSize=-(area($SucTraceTempFS,plateauCross,(BeginP+EndP)/2)-SS_F*(((BeginP+EndP)/2)-plateauCross))
print "Pool size = ", PoolSize

i=x2pnt($SucTraceTempFS, minT_F)
print "searching for level ", (SS_F+PeakF)/2
do
	i-=1
while($SucTraceTempFS[i]<(SS_F+PeakF)/2)
HalfTimeB=pnt2x($SucTraceTempFS, i)
print "plateau Crossing = ", HalfTimeB
i=x2pnt($SucTraceTempFS, minT_F)
do
	i+=1
while($SucTraceTempFS[i]<(SS_F+PeakF)/2)
HalfTimeA=pnt2x($SucTraceTempFS, i)
print "plateau Crossing = ", HalfTimeA

HalfTime=HalfTimeA-HalfTimeB
print "Half-Time of peak = ", HalfTime

duplicate /O/R=(plateauCross,(BeginP+EndP)/2) $SucTracetempFS $SucTraceTempPool
duplicate /O $SucTraceTempPool $SucTraceTempBase
$SucTraceTempBase=SS_F

$HalfLineT[0]=HalfTimeB
$HalfLineT[1]=HalfTimeA
$HalfLine[0]=(SS_F+PeakF)/2
$HalfLine[1]=(SS_F+PeakF)/2

Display $SucTraceTempPool, $SucTraceTempBase

ModifyGraph mode($SucTraceTempPool)=7;DelayUpdate
ModifyGraph toMode($SucTraceTempPool)=1;DelayUpdate
ModifyGraph plusRGB($SucTraceTempPool)=(44032,29440,58880);DelayUpdate
ModifyGraph negRGB($SucTraceTempPool)=(43520,43520,43520)

AppendToGraph $SucTracetempFS
AppendToGraph $HalfLine vs $HalfLineT
ModifyGraph marker($HalfLine)=1;DelayUpdate
ModifyGraph rgb($HalfLine)=(0,0,0)
ModifyGraph mode($HalfLine)=4

ModifyGraph useNegRGB($SucTraceTempPool)=1;DelayUpdate
ModifyGraph usePlusRGB($SucTraceTempPool)=1;DelayUpdate
ModifyGraph hbFill($SucTraceTempPool)=2;DelayUpdate
ModifyGraph useNegPat($SucTraceTempPool)=1;DelayUpdate
ModifyGraph hBarNegFill($SucTraceTempPool)=2

Textbox/C/N=text1/A=RT/X=0/Y=65"Time of minimum (filtered) :\t"+num2str(minT_F)+ "s"+ "\rHalftime is:                       \t" + num2str(HalfTimeB)+"s" + "\rHalfduration is:                       \t" + num2str(HalfTime)+"s" + "\rPool estimate is:               \t"+num2str(PoolSize)+"C"

end


