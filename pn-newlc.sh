### Script to create EPIC pn light curves

ulimit -d 1500000

dir=${PWD}/
odir=${dir}
out=${odir}lightcurves/
export SAS_ODF=${dir}odf/
export SAS_CCF=${dir}ccf.cif
export SAS_CCFPATH=/opt/xmm-newton-ccf/
echo "Creating PN light curves"
outset="timebinsize=10 maketimecolumn=yes makeratecolumn=yes rateset"

# Retrieve the PN event list.
# eventlist="$(ls *PIEVLI*)"
# idshort=${eventlist:8:3}
eventlist=$1
idshort=$2
histo=$4
gticr=$5
#srcz=$6

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

# Input information
echo "*****"
echo "Event list: ${eventlist}"
echo "Src region: ${srcreg}"
echo "Bkg region: ${bkgreg}"
echo "*****"

if [ ${gticr} -gt 0 ]
then
	tabgtigen table=${dir}${histo} gtiset=${idshort}_gti.fits expression="COUNTS<=${gticr}"
	pat="FLAG==0 .and. #XMMEA_EP .and. PATTERN>-1 .and. PATTERN<5 .and. GTI(${odir}${idshort}_gti.fits,TIME) "
fi

if [ ${gticr} -lt 0 ]
then
	pat="FLAG==0 .and. #XMMEA_EP .and. PATTERN>-1 .and. PATTERN<5  "
fi

# ################################ PN Light Curve Creation
# low=300
# hi=10000
# 
# pi="PI.ge.${low} .and. PI.le.${hi}"
# pat="FLAG==0 .and. #XMMEA_EP .and. PATTERN>-1 .and. PATTERN<5  "
# # pat="FLAG==0 .and. #XMMEA_EP .and. PATTERN>-1 .and. PATTERN<5 .and. GTI(${odir}${id}_gti.fits,TIME) "  #created with spectra
# 
# ### Source
# evselect table=${dir}${id}.FIT energycolumn=PI withrateset=true \
# expression="CIRCLE(${reg_sc},${rad},X,Y) .and. $pat .and. $pi" \
# $outset=${out}${idshort}pn_lc_raw_${low}-${hi}.fits
# 
# # ### PILE UP --- Source --- PILE UP ###
# # evselect table=${dir}${id}.FIT energycolumn=PI withrateset=true \
# # expression="annulus(${reg_sc},${radin},${rad},X,Y) .and. $pat .and. $pi" \
# # $outset=${out}${idshort}pn_lc_raw_${low}-${hi}.fits
# # ### PILE UP --- Source --- PILE UP ###
# 
# ### Background
# evselect table=${dir}${id}.FIT energycolumn=PI withrateset=true \
# expression="CIRCLE(${reg_bg},${brad},X,Y) .and. $pat .and. $pi" \
# $outset=${out}${idshort}pn_bg_raw_${low}-${hi}.fits
# 
# epiclccorr srctslist=${out}${idshort}pn_lc_raw_${low}-${hi}.fits eventlist=${dir}${id}.FIT \
# outset=${out}${idshort}pn_lccor_${low}-${hi}.fits bkgtslist=${out}${idshort}pn_bg_raw_${low}-${hi}.fits \
# withbkgset=yes applyabsolutecorrections=yes
# ################################


###############################
### Making LCs broad band, low & high energy -----------------------------------------
# declare -a lowarr=("500" "500" "2000")
# declare -a hiarr=("10000" "1500" "10000")
# declare -a lowarr=("500" "500" "2000" "500" "700" "1000" "1400" "1900" "2700" "3800" "5300" "7400")
# declare -a hiarr=("10000" "1500" "10000" "700" "1000" "1400" "1900" "2700" "3800" "5300" "7400" "10000")
# declare -a lowarr=("500" "500" "1500" "4000")
# declare -a hiarr=("10000" "1500" "4000" "10000")
# declare -a lowarr=("300" "300" "1000" "300" "1000" "300" "425" "600" "850" "1200" "1700" "2500" "3500" "5000" "7000")
# declare -a hiarr=("10000" "1000" "4000" "800" "3000" "425" "600" "850" "1200" "1700" "2500" "3500" "5000" "7000" "10000")
# declare -a lowarr=("300" "300" "2000")
# declare -a hiarr=("10000" "1000" "10000")

declare -a lowarr=("300" "300" "1000" "4000" "2000")
declare -a hiarr=("10000" "1000" "4000" "10000" "10000")

#declare -a lowarr=("300" "350" "425" "500" "600" "720" "850" "1000" "1200" "1450" "1750" "2000" "2450" "2900" "3500" "4150" "5000" "6000" "7000" "8000")
#declare -a hiarr=("350" "425" "500" "600" "720" "850" "1000" "1200" "1450" "1750" "2000" "2450" "2900" "3500" "4150" "5000" "6000" "7000" "8000" "10000")

# declare -a lowarr=("500" "500" "2000" "1500" "4000")
# declare -a hiarr=("10000" "1500" "10000" "4000" "10000")
# declare -a lowarr=("300" "400" "540" "720" "965" "1300" "1750" "2300" "3100" "4100" "5600" "7500")
# declare -a hiarr=("400" "540" "720" "965" "1300" "1750" "2300" "3100" "4100" "5600" "7500" "10000")
COUNTER=0
while [ $COUNTER -lt ${#lowarr[@]} ]
do
	echo "**********"
	echo "Making the ${lowarr[COUNTER]}eV - ${hiarr[COUNTER]}eV light curve..."
	rlow=${lowarr[COUNTER]}
	rhi=${hiarr[COUNTER]}
	low=${lowarr[COUNTER]}
	hi=${hiarr[COUNTER]}
	#low=$(bc -l <<< "scale=4; ${lowarr[COUNTER]}/(1.0+${srcz})")
	#hi=$(bc -l <<< "scale=4; ${hiarr[COUNTER]}/(1.0+${srcz})")
	echo "${low}-${hi} keV in source frame"

	pi="PI.ge.${low} .and. PI.le.${hi}"

	## NORMAL ###
	evselect table=${eventlist} energycolumn=PI withrateset=true \
	expression="${srcreg} .and. $pat .and. $pi" \
	$outset=${out}${idshort}pn_lc_raw_${rlow}-${rhi}.fits
	## NORMAL ###
	
	# ### PILE UP --- Source --- PILE UP ###
	# evselect table=${eventlist} energycolumn=PI withrateset=true \
	# expression="annulus(${reg_sc},${radin},${rad},X,Y) .and. $pat .and. $pi" \
	# $outset=${out}${idshort}pn_lc_raw_${rlow}-${rhi}.fits
	# ### PILE UP --- Source --- PILE UP ###

	evselect table=${eventlist} energycolumn=PI withrateset=true \
	expression="${bkgreg} .and. $pat .and. $pi" \
	$outset=${out}${idshort}pn_bg_raw_${rlow}-${rhi}.fits

	epiclccorr srctslist=${out}${idshort}pn_lc_raw_${rlow}-${rhi}.fits eventlist=${eventlist} \
	outset=${out}${idshort}pn_lccor_${rlow}-${rhi}.fits bkgtslist=${out}${idshort}pn_bg_raw_${rlow}-${rhi}.fits \
	withbkgset=yes applyabsolutecorrections=yes

	echo "...done!"
	echo "**********"
	echo ""
	let COUNTER=COUNTER+1
done
###############################


################################
# ### Making LCs for lag-energy spectra -----------------------------------------
# #declare -a arr=("300" "400" "500" "600" "700" "800" "1000" "1300" "1600" "2000" "2500" "3000" "3500" "4000" "5000" "6000" "7000" "8000" "10000")
# declare -a arr=("300" "425" "600" "850" "1200" "1750" "2500" "3500" "5000" "7000" "10000")
# COUNTER=0
# while [ $COUNTER -lt ${#arr[@]} ]
# do
# 	echo "**********"
# 	echo "Making the ${arr[COUNTER]}eV - ${arr[COUNTER+1]}eV light curve..."
# 	low=${arr[COUNTER]}
# 	hi=${arr[COUNTER+1]}
# 
# 	pi="PI.ge.${low} .and. PI.le.${hi}"
# 	#pat="FLAG==0 .and. #XMMEA_EP .and. PATTERN>-1 .and. PATTERN<5 .and. GTI(${odir}${id}_gti.fits,TIME) "  #created with spectra
# 	pat="FLAG==0 .and. #XMMEA_EP .and. PATTERN>-1 .and. PATTERN<5  "
# 
# 	evselect table=${dir}${id}.FIT energycolumn=PI withrateset=true \
# 	expression="CIRCLE(${reg_sc},${rad},X,Y) .and. $pat .and. $pi" \
# 	$outset=${out}${idshort}pn_lc_raw_${low}-${hi}.fits
# 
# 	evselect table=${dir}${id}.FIT energycolumn=PI withrateset=true \
# 	expression="CIRCLE(${reg_bg},${brad},X,Y) .and. $pat .and. $pi" \
# 	$outset=${out}${idshort}pn_bg_raw_${low}-${hi}.fits
# 
# 	epiclccorr srctslist=${out}${idshort}pn_lc_raw_${low}-${hi}.fits eventlist=${dir}${id}.FIT \
# 	outset=${out}${idshort}pn_lccor_${low}-${hi}.fits bkgtslist=${out}${idshort}pn_bg_raw_${low}-${hi}.fits \
# 	withbkgset=yes applyabsolutecorrections=yes
# 
# 	echo "...done!"
# 	echo "**********"
# 	echo ""
# 	let COUNTER=COUNTER+1
# done
################################
