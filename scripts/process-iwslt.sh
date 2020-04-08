#!/bin/sh

ROOT_DIR=$(pwd)
TGT=en

# TODO: download iwslt data

clean_folder () {
    mkdir $1
    for f in $(ls ./IWSLT*$1* | head -2)
    do
        mv $f ./$1
    done
    rm *
}

# create folders and extract everything
for f in ./*.tgz
do
    tar xvf $f
done

# remove all tarballs
rm *.tgz

#ar: dev2010 tst2010 tst2011 tst2012 tst2013 tst2014
#cs: dev2010 tst2010 tst2011 tst2012 tst2013
#tr: dev2010 tst2010 tst2011 tst2012
