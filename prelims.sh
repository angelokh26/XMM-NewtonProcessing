######## first make your tables from these defined event files ###########

### for the pn data:
pnfile=$1
#pnfile="$(find . -name "*S002PIEVLI*.FIT")"
evselect table=${pnfile} withhistogramset=true histogramcolumn=TIME \
expression="PI.gt.10000" histogramset=pn_histo.fits

### Loop through the srcbkg region file and collect the regions

#srcbkg=$2

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
done < "$2"

### Display the collected regions
echo "Src region: ${srcreg}"
echo "Bkg region: ${bkgreg}"

### for the MOS data 1 and 2:
# evselect table=P0127110201M1U009MIEVLI0000.FIT  withhistogramset=true histogramcolumn=TIME \
# expression="PI.gt.10000" histogramset=m1_histo.fits
#
# evselect table=P0127110201M2U009MIEVLI0000.FIT withhistogramset=true histogramcolumn=TIME \
# expression="PI.gt.10000" histogramset=m2_histo.fits

######## then plot these files using the defined box/circle parameters ##########
dsplot table=pn_histo.fits withx=true withy=true x=TIME y=COUNTS
# dsplot table=m1_histo.fits withx=true withy=true x=TIME y=COUNTS
# dsplot table=m2_histo.fits withx=true withy=true x=TIME y=COUNTS

export SAS_CCFPATH=/opt/xmm-newton-ccf/
export SAS_ODF=${PWD}/odf
export SAS_CCF=./ccf.cif

### For TIMING MODE ###
#evselect table=P0655590501PNS600PIEVLI0000.FIT withfilteredset=true destruct=yes \
#keepfilteroutput=true expression="box(57,101,1.5,99.5,0, X, Y)" \
#filteredset=pn_box.fits

#epatplot set=pn_box.fits

### For NORMAL ###
### EPIC pn
evselect table=${pnfile} withfilteredset=true destruct=yes \
keepfilteroutput=true expression="${srcreg}" \
filteredset=pn_circle.fits

epatplot set=pn_circle.fits

### MOS 1&2
# evselect table=P0127110201M1U009MIEVLI0000.FIT  withfilteredset=true destruct=yes keepfilteroutput=true expression="circle(24413.392,24459.434,700, X, Y)" filteredset=m1_circle.fits
# epatplot set=m1_circle.fits
#
# evselect table=P0127110201M2U009MIEVLI0000.FIT  withfilteredset=true destruct=yes keepfilteroutput=true expression="circle(24422.521,24457.434,700, X, Y)" filteredset=m2_circle.fits
# epatplot set=m2_circle.fits

gv pn_circle_pat.ps &
# gv m1_circle_pat.ps &
# gv m2_circle_pat.ps &
