#!/bin/sh

# Extracts the zip file of IWSLT data sets into the following structure:

#├── ar-en
#│   ├── dev
#│   │   ├── iwslt.ted.dev2010.ar-en.ar.xml
#│   │   ├── ...
#│   └── testing
#│       ├── iwslt.ted.tst2013.ar-en.ar.xml
#│       ├── ...
#├── cs-en
#│   ├── dev
#│   └── testing
#└── tr-en
#    ├── dev
#    └── testing


# Details from paper (Table 6)
#    ar: dev2010 tst2010 tst2011 tst2012 tst2013 tst2014
#    cs: dev2010 tst2010 tst2011 tst2012 tst2013
#    tr: dev2010 tst2010 tst2011 tst2012

# preferably get this from the script calling it 
IWSLT_ZIP_FILE=$1
if [ -z $IWSLT_ZIP_FILE ]
then
    IWSLT_ZIP_FILE="all-iwslt.zip"
fi

unzip $IWSLT_ZIP_FILE

TGT=en
# create folders and extract everything
for f in ./*.tgz
do
    tar xvf $f
done

# remove all tarballs
rm *.tgz


for SRC in ar cs tr
do

    cd ${SRC}-${TGT} # this exists b/c of tarball contents
    
    case "${SRC}" in
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
            grep "IWSLT1[0-9].TED.${DATASET}.${SRC}-${TGT}.[${SRC}|${TGT}]" | \
               head -n 2)
        do
            mv $f tmp/$(echo $f | sed s/"IWSLT.*\.TED"/iwslt.ted/g)
        done
    done

    mkdir dev
    mkdir testing

    echo "Source: "$SRC
    echo "Target: "$TGT

    for DEV_DATASET in $DEV_DATASETS
    do
        mv tmp/*$DEV_DATASET* dev/
    done

    for TEST_DATASET in $TEST_DATASETS
    do
        ls tmp
        mv tmp/*$TEST_DATASET* testing/
    done

    cd ..
    rm ${SRC}-${TGT}/*
    mv ${SRC}-${TGT}/tmp/* ${SRC}-${TGT}

    rm -R ${SRC}-${TGT}/tmp

done
