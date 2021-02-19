## process.com
## process XMM ODF files, in particular the SUM.SAS
##
## also creates calibrated event list from the
## complete odfs for the pn, moss, and rgss
##

## large memory requirements for SAS
## this step may or may not be required
#export SAS_MEMORY_MODEL=low

## activate XMMSAS - not required usually since
## already included in the login
#source /util/xmmsas-setup.sh


## capitalize filenames
#uc-tree outdirname

## Define the current calibration file
export SAS_CCFPATH=/opt/xmm-newton-ccf/

## to created ODFs
export SAS_ODF=${PWD}/odf

## Create a Calibration Index File (CIF)
cifbuild

## Set the current calibration file to the CIF
export SAS_CCF=./ccf.cif

## Create ODF Summary file  ...SUM.SAS
odfingest outdir=$SAS_ODF odfdir=$SAS_ODF

## To create a calibrated event list for the pn
epchain datamode=IMAGING odfaccess=all
echo "EPCHAIN DONE"
#epproc
#echo "EPPROC DONE"

# # To create a calibrated event list for the MOSs
# emchain
# echo "emchain done"

## To create a calibrated event list for the RGSs
#rgsproc

# ## For OM
# ## omflatgen outset='1332_0400070401_OMX00000NPH.FIT'
# # export SAS_ODF=${PWD}/odf/3070_0790590101_SCX00000SUM.SAS
# export SAS_ODF="$(ls odf/*SUM.SAS)"
# omichain outdirectory=${PWD}/omi
# echo "omchain done"
# omsrclist="$(ls *COMBOBSMLI*.FIT)"
# om2pha srclist=${omsrclist} ra=51.171505 dec=34.179404 tolerance=30 output=spec.pha > om2pha.out 2>&1
# #omfchain outdirectory=${PWD}/omf/
# #echo "omfchain done"

## create image of pn in timing mode 
#evselect table=P0112320201PNS003TIEVLI0000.FIT withfilteredset=true destruct=yes \
#keepfilteroutput=true expression="PI.gt.300" #filteredset=P0112320201PNS003TIEVLI0000_pi300.fits
#evselect table=P0112320201PNS003TIEVLI0000_pi300.fits withimageset=true #imageset=PNimage.fits

##create a 1D image to see where on the CCD the object is:
#evselect table=P0112320201PNS003TIEVLI0000_pi300.fits withimageset=true #imagebinning=imageSize \
#yimagebinsize=200 imageset=PNimage_cut.fits
