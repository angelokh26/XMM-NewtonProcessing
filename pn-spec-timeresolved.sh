# ulimit -d 1500000
# 
# export SAS_CCFPATH=/opt/xmm-newton-ccf/
# 
# echo "Creating Spectral Files"
# 
# specr="withspecranges=true specchannelmin=0 specchannelmax=20479 "
# specs="spectralbinsize=5 energycolumn=PI withspectrumset=true"
# spec=$specr$specs
# outset="keepfilteroutput=true withfilteredset=true destruct=true filteredset"
# 
# 
# bin=20
# 
# ################################
# dir=${PWD}/
# odir=${dir}spectra/time_resolved/10000s/
# out=${odir}
# 
# id=P0206860201PNS003PIEVLI0000
# idshort=04201
# 
# reg_sc='27007.492,27630.554'
# rad=700
# reg_bg='29183.536,24670.576'
# brad=1000
# 
# ## set ODF directory and ccf
# export SAS_ODF=${dir}odf/
# export SAS_CCF=${dir}ccf.cif
# 
# # ## Create GTI if necessary
# # #tabgtigen table=${dir}pn_histo.fits gtiset=${id}_gti.fits expression="COUNTS.lt.20"
# #
# # ## Specify pattern (with or without GTI)
# # #pat="FLAG==0 && PATTERN>-1 && PATTERN<5"
# # #pat="FLAG==0 && PATTERN>-1 && PATTERN<5 && GTI(${id}_gti.fits,TIME) "
# # pat="TIME.lt.361103217 && FLAG==0 && PATTERN>-1 && PATTERN<5"
# # pat="TIME.ge.361103217 && TIME.lt.361113217 && FLAG==0 && PATTERN>-1 && PATTERN<5"
# # pat="TIME.ge.361213217 && FLAG==0 && PATTERN>-1 && PATTERN<5"
# #
# # ## Create source spectrum
# # echo evselect table=${dir}${eventlist} expression="CIRCLE(${reg_sc},${rad},X,Y) && $pat" $spec spectrumset=${out}${idshort}pn_sc_SD.pha
# # evselect table=${dir}${eventlist} expression="CIRCLE(${reg_sc},${rad},X,Y) && $pat" $spec spectrumset=${out}${idshort}pn_sc_SD.pha
# #
# # ##Create background spectrum
# # echo evselect table=${dir}${eventlist} expression="CIRCLE(${reg_bg},${brad},X,Y) && $pat" $spec spectrumset=${out}${idshort}pn_bg_SD.pha
# # evselect table=${dir}${eventlist} expression="CIRCLE(${reg_bg},${brad},X,Y) && $pat" $spec spectrumset=${out}${idshort}pn_bg_SD.pha
# #
# # ## Calculate and apply backscale
# # backscale spectrumset=${out}${idshort}pn_sc_SD.pha withbadpixcorr=yes badpixlocation=${dir}${eventlist}
# # backscale spectrumset=${out}${idshort}pn_bg_SD.pha withbadpixcorr=yes badpixlocation=${dir}${eventlist}
# #
# # ## Create arf & rmf files
# # arfgen spectrumset=${out}${idshort}pn_sc_SD.pha arfset=${out}${idshort}pn_sc_SD.arf detmaptype=psf badpixlocation=${dir}${eventlist}
# # rmfgen spectrumset=${out}${idshort}pn_sc_SD.pha rmfset=${out}${idshort}pn_sc_SD.rmf
# #
# # ## Group the spectra and such
# # #specgroup spectrumset=${out}${idshort}pn_sc_SD.pha mincounts=25 oversample=3 rmfset=${out}${idshort}pn_sc_SD.rmf arfset=${out}${idshort}pn_sc_SD.arf backgndset=${out}${idshort}pn_bg_SD.pha groupedset=${out}${idshort}pn_grouped_SD.pha

### Script to create EPIC pn spectra

ulimit -d 1500000

dir=${PWD}/
odir=${dir}
out=${odir}spectra/
export SAS_ODF=${dir}odf/
export SAS_CCF=${dir}ccf.cif
export SAS_CCFPATH=/opt/xmm-newton-ccf/

echo "Creating Spectral Files"
specr="withspecranges=true specchannelmin=0 specchannelmax=20479 "
specs="spectralbinsize=5 energycolumn=PI withspectrumset=true"
spec=$specr$specs
outset="keepfilteroutput=true withfilteredset=true destruct=true filteredset"

# Retrieve the PN event list.
#eventlist="$(ls *PIEVLI*)"
#idshort=${eventlist:8:3}
eventlist=$1
idshort=$2
histo=$4
gticr=$5

# Set up a counter, loop through the srcbkg.reg file and extract src and bkg regions.
i=0
while IFS= read -r line ; do
	i=$((i + 1))
	if (( ${i} == 4)) ; then
		srcrad=${line:(-4):3}
		srcreg=${line/)/,X,Y)}
	fi
	if (( ${i} == 5)) ; then
		bkgrad=${line:(-5):4}
		bkgreg=${line/)/,X,Y)}
	fi
done < "$3"
areascale=$(bc -l <<< "scale=4; ${bkgrad}^2/${srcrad}^2")

# Input information
echo "*****"
echo "Event list: ${eventlist}"
echo "Output stem: ${idshort}"
echo "Histogram: ${histo}"
echo "Src region: ${srcreg}"
echo "Bkg region: ${bkgreg}"
echo "*****"

# if [ ${gticr} -gt 0 ]
# then
# 	tabgtigen table=${dir}pn_histo.fits gtiset=${idshort}_specgti.fits expression="COUNTS<=${gticr}"
# 	pat="FLAG==0 && PATTERN>-1 && PATTERN<5 && GTI(${dir}${idshort}_specgti.fits,TIME)"
# fi
# 
# if [ ${gticr} -lt 0 ]
# then
# 	pat="FLAG==0 && PATTERN>-1 && PATTERN<5"
# fi


#starttime=584396463
#endtime=$((starttime+140219))
#timeseg=35000
starttime=$6
endtime=$7
timeseg=$8
currenttime=${starttime}

while [ $((currenttime+timeseg)) -lt ${endtime} ]
do
	nexttime=$((currenttime+timeseg))
	segstart=$(((currenttime-starttime)/1000))
	segend=$(((nexttime-starttime)/1000))
	echo "**********"
	echo "Making the ${segstart}ks - ${segend}ks spectrum..."

	if [ ${gticr} -gt 0 ]
	then
	rm ${idshort}_specgti.fits
	tabgtigen table=${dir}${histo} gtiset=${idshort}_specgti.fits expression="COUNTS<=${gticr}"
	pat="TIME.ge.${currenttime} && TIME.lt.${nexttime} && FLAG==0 && PATTERN>-1 && PATTERN<5 && GTI(${idshort}_specgti.fits,TIME)"
	fi

	if [ ${gticr} -lt 0 ]
	then
	pat="TIME.ge.${currenttime} && TIME.lt.${nexttime} && FLAG==0 && PATTERN>-1 && PATTERN<5"
	fi

	## Create source spectrum
	echo evselect table=${dir}${eventlist} expression="${srcreg} && $pat" $spec spectrumset=${out}${idshort}pn_${segstart}-${segend}_src.pha
	evselect table=${dir}${eventlist} expression="${srcreg} && $pat" $spec spectrumset=${out}${idshort}pn_${segstart}-${segend}_src.pha

	##Create background spectrum
	echo evselect table=${dir}${eventlist} expression="${bkgreg} && $pat" $spec spectrumset=${out}${idshort}pn_${segstart}-${segend}_bkg.pha
	evselect table=${dir}${eventlist} expression="${bkgreg} && $pat" $spec spectrumset=${out}${idshort}pn_${segstart}-${segend}_bkg.pha

	## Calculate and apply backscale
	backscale spectrumset=${out}${idshort}pn_${segstart}-${segend}_src.pha withbadpixcorr=yes badpixlocation=${dir}${eventlist}
	backscale spectrumset=${out}${idshort}pn_${segstart}-${segend}_bkg.pha withbadpixcorr=yes badpixlocation=${dir}${eventlist}

	## Create arf & rmf files
	arfgen spectrumset=${out}${idshort}pn_${segstart}-${segend}_src.pha arfset=${out}${idshort}pn_${segstart}-${segend}.arf detmaptype=psf badpixlocation=${dir}${eventlist}
	rmfgen spectrumset=${out}${idshort}pn_${segstart}-${segend}_src.pha rmfset=${out}${idshort}pn_${segstart}-${segend}.rmf

	### For use with C-statistics
	## Adjust the area scaling of the background, used in background modelling
	grppha infile=${out}${idshort}pn_${segstart}-${segend}_bkg.pha outfile=${out}${idshort}pn_${segstart}-${segend}_bkgscaled.pha comm="chkey AREASCAL ${areascale} & exit"
	
	## Optimally bin the spectra 
	cd ${out}
	ftgrouppha infile=${idshort}pn_${segstart}-${segend}_src.pha outfile=${idshort}_opt_${segstart}-${segend}_src.pha respfile=${idshort}pn_${segstart}-${segend}.rmf grouptype=opt
	ftgrouppha infile=${idshort}pn_${segstart}-${segend}_bkgscaled.pha outfile=${idshort}_opt_${segstart}-${segend}_bkg.pha respfile=${idshort}pn_${segstart}-${segend}.rmf grouptype=opt
	cd ../

	currenttime=${nexttime}
	echo "...done!"
	echo "**********"
	echo ""
done

###############################
