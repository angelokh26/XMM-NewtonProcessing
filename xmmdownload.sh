#XMM Pre-processing script
# Author: Derek Blue
if [ $# -gt 0 ]; then
    for obsid in "$@"
    do
        echo "Downloading observation ${obsid}"
        curl -o ${obsid}.tar "http://nxsa.esac.esa.int/nxsa-sl/servlet/data-action-aio?obsno=${obsid}"
        tar xvf ${obsid}.tar
        rm ${obsid}.tar
        cd ${obsid}/odf
        tar xvfz ${obsid}.tar.gz
        odftar="$(find . -name "*.TAR")"
        tar xvf ${odftar}
    done
fi
