#!/bin/sh

ROOT_DIR=$(pwd)
TGT=en

#ar: dev2010 tst2010 tst2011 tst2012 tst2013 tst2014
#cs: dev2010 tst2010 tst2011 tst2012 tst2013
#tr: dev2010 tst2010 tst2011 tst2012

# TODO: download iwslt data
#wget https://j0ma.keybase.pub/datasets/all-iwslt.zip
unzip all-iwslt.zip

# create folders and extract everything
for f in ./*.tgz
do
    tar xvf $f
done

# remove all tarballs
rm *.tgz


for SRC in ar cs tr
do
    case "${SRC}" in
        ar)
            DATASETS=$(echo "dev2010 tst2010 tst2011 tst2012 tst2013 tst2014" | \
                       sed s/" "/"\n"/g);;
        cs)
            DATASETS=$(echo "dev2010 tst2010 tst2011 tst2012 tst2013" | \
                       sed s/" "/"\n"/g);;
        tr)
            DATASETS=$(echo "dev2010 tst2010 tst2011 tst2012" | \
                       sed s/" "/"\n"/g);;
    esac

    cd ${SRC}-${TGT} # this exists b/c of tarball contents
    for DATASET in $DATASETS
    do
        #grep -E "IWSLT[1-9].*"$SRC"-"$TGT"\.("$SRC"|"$TGT")")
        for f in $(ls *${DATASET}* | \
            grep "IWSLT1[0-9].TED.${DATASET}.${SRC}-${TGT}.[${SRC}|${TGT}]" | \
            head -n 2)
        do
            mkdir -p $DATASET
            mv $f $DATASET
        done
    done
    cd ..
    rm ${SRC}-${TGT}/*
done

echo "at end working directory is: $(pwd)"
