#!/bin/sh

# Extracts the zip file of IWSLT data sets 

# Details from paper (Table 6)
#    ar: dev2010 tst2010 tst2011 tst2012 tst2013 tst2014
#    cs: dev2010 tst2010 tst2011 tst2012 tst2013
#    tr: dev2010 tst2010 tst2011 tst2012

# preferably get this from the script calling it 
IWSLT_ZIP_FILE=$1
DATA_PATH=$2
SCRIPTS_DIR=$3

if [ -z $IWSLT_ZIP_FILE ]
then
    IWSLT_ZIP_FILE="all-iwslt.zip"
fi

echo "Unzipping $IWSLT_ZIP_FILE"
unzip $IWSLT_ZIP_FILE

SRC=en
# create folders and extract everything
for f in ./*.tgz
do
    tar xvf $f
done

# remove all tarballs
rm *.tgz

for TGT in ar cs tr
do

    mv ${TGT}-${SRC} ${SRC}-${TGT}
    cd ${SRC}-${TGT} # this exists b/c of tarball contents
    
    case "${TGT}" in
        ar)
            DATASETS=$(echo "dev2010 tst2010 tst2011 tst2012 tst2013 tst2014" | \
                       sed s/" "/"\n"/g)

            DEV_DATASETS=$(echo "dev2010 tst2010 tst2011 tst2012" | sed s/" "/"\n"/g)
            TEST_DATASETS=$(echo "tst2013 tst2014"| sed s/" "/"\n"/g);;

        cs)
            DATASETS=$(echo "dev2010 tst2010 tst2011 tst2012 tst2013" | \
                       sed s/" "/"\n"/g)
            DEV_DATASETS=$(echo "dev2010 tst2010 tst2011" | sed s/" "/"\n"/g)
            TEST_DATASETS=$(echo "tst2012 tst2013"| sed s/" "/"\n"/g);;
        tr)
            DATASETS=$(echo "dev2010 tst2010 tst2011 tst2012" | \
                       sed s/" "/"\n"/g)
            DEV_DATASETS=$(echo "dev2010 tst2010" | sed s/" "/"\n"/g)
            TEST_DATASETS=$(echo "tst2011 tst2012"| sed s/" "/"\n"/g);;
    esac

    for DATASET in $DATASETS
    do
        mkdir -p tmp
        for f in $(ls *${DATASET}* | \
            grep "IWSLT1[0-9].TED.${DATASET}.${TGT}-${SRC}.[${TGT}|${SRC}]" | \
               head -n 2)
        do
            new_file=tmp/$(echo $f | sed s/"IWSLT.*\.TED"/iwslt.ted/g | sed s/"${TGT}-${SRC}"/"${SRC}-${TGT}"/g)
            mv $f $new_file
        done
    done

    mkdir "dev"
    mkdir "test"

    for DEV_DATASET in $DEV_DATASETS
    do
        mv tmp/*$DEV_DATASET* dev/
    done

    for TEST_DATASET in $TEST_DATASETS
    do
        mv tmp/*$TEST_DATASET* test/
    done

    cd ..
    rm ${SRC}-${TGT}/*
    mv ${SRC}-${TGT}/tmp/* ${SRC}-${TGT}

    rm -R ${SRC}-${TGT}/tmp

    cd ${SRC}-${TGT}
    for folder in dev test
    do
        cd ${folder}
        grep "<seg id" *.${SRC}.xml \
            | grep -oE "> (.*) <" \
            | sed s/"[\<|\>]"/""/g \
            | sed s/"^ "/""/g \
            | sed s/" $"/""/g > ${folder}.${SRC}

        grep "<seg id" *.${TGT}.xml \
            | grep -oE "> (.*) <" \
            | sed s/"[\<|\>]"/""/g \
            | sed s/"^ "/""/g \
            | sed s/" $"/""/g > ${folder}.${TGT}
        rm *.xml
        cd ..
    done
    cd ..

done
