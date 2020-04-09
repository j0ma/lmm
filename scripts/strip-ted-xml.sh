#!/bin/sh

# Description: Prepares TED talk data for single language pair.
#              Very much based on the WIT3 processing scripts.

# Written by Jonne Saleva, 2020

SRC_LANG=$1
TGT_LANG=$2
SCRIPTS_PATH=$3
TED_PATH=$4
SCRIPTS_DIR="${SCRIPTS_PATH}/perl"
WORKING_DIR="${TED_PATH}/ted-staging"
INPUT_DIR="${TED_PATH}/ted-raw"
OUTPUT_DIR="${TED_PATH}/${SRC_LANG}-${TGT_LANG}/train"

echo "Preparing data for ${SRC_LANG} ${TGT_LANG} ..."

echo "Creating staging directory at ${WORKING_DIR} ..."
mkdir -p $WORKING_DIR

echo "Creating output directory at ${OUTPUT_DIR} ..."
mkdir -p $OUTPUT_DIR

# empty dirs
rm -f $WORKING_DIR/*
rm -f $OUTPUT_DIR/*

############################
### find-common-talks.pl ###
############################
echo "Finding common talks between ${SRC_LANG} and ${TGT_LANG}"
SRC_XML_FILE=$(ls ${INPUT_DIR}/ted_${SRC_LANG}-*.xml)
TGT_XML_FILE=$(ls ${INPUT_DIR}/ted_${TGT_LANG}-*.xml)
OUTPUT_FILE_ALL=$WORKING_DIR/talkid_${SRC_LANG}-${TGT_LANG}.all

echo "Saving output to $OUTPUT_FILE_ALL"

perl $SCRIPTS_DIR/find-common-talks.pl \
    --xml-file-l1 $SRC_XML_FILE \
    --xml-file-l2 $TGT_XML_FILE > $OUTPUT_FILE_ALL

echo "Splitting to train and test..."
OUTPUT_FILE_TRAIN=$WORKING_DIR/talkid_${SRC_LANG}-${TGT_LANG}.train
OUTPUT_FILE_TEST=$WORKING_DIR/talkid_${SRC_LANG}-${TGT_LANG}.test

echo "Saving test set (first 10 data points) to ${OUTPUT_FILE_TEST}"
head -10 $OUTPUT_FILE_ALL > $OUTPUT_FILE_TEST

echo "Saving training set to ${OUTPUT_FILE_TRAIN}"
tail -n +11 $OUTPUT_FILE_ALL > $OUTPUT_FILE_TRAIN

############################
###     find-talks.pl    ###
############################

echo "Finding set of talks in ${TGT_LANG} that are disjoint from test set"
OUTPUT_FIND_TALKS_ALL=$WORKING_DIR/talkid_${TGT_LANG}.all
OUTPUT_FIND_TALKS_TRAIN=$WORKING_DIR/talkid_${TGT_LANG}.train

perl $SCRIPTS_DIR/find-talks.pl \
    --xml-file $TGT_XML_FILE > $OUTPUT_FIND_TALKS_ALL

egrep -v -w -f \
    $OUTPUT_FILE_TEST \
    $OUTPUT_FIND_TALKS_ALL > $OUTPUT_FIND_TALKS_TRAIN

############################
###    filter-talks.pl   ###
############################

# Select specific set of talks from the whole collection:

# training parallel: 
FILTER_TALKS_TRAIN_SRC=$WORKING_DIR/ted_${SRC_LANG}-${TGT_LANG}.train.${SRC_LANG}.xml
perl $SCRIPTS_DIR/filter-talks.pl \
    --talkids $OUTPUT_FILE_TRAIN \
    --xml-file $SRC_XML_FILE > $FILTER_TALKS_TRAIN_SRC

FILTER_TALKS_TRAIN_TGT=$WORKING_DIR/ted_${SRC_LANG}-${TGT_LANG}.train.${TGT_LANG}.xml
perl $SCRIPTS_DIR/filter-talks.pl \
    --talkids $OUTPUT_FILE_TRAIN \
    --xml-file $TGT_XML_FILE > $FILTER_TALKS_TRAIN_TGT

# training monolingual: 
TED_TRAIN_TGT=$WORKING_DIR/ted_train.${TGT_LANG}.xml
perl $SCRIPTS_DIR/filter-talks.pl \
    --talkids $OUTPUT_FIND_TALKS_TRAIN \
    --xml-file $TGT_XML_FILE > $TED_TRAIN_TGT

# test:
FILTER_TALKS_TEST_SRC=$WORKING_DIR/ted_${SRC_LANG}-${TGT_LANG}.test.${SRC_LANG}.xml
perl $SCRIPTS_DIR/filter-talks.pl \
    --talkids $OUTPUT_FILE_TEST \
    --xml-file $SRC_XML_FILE > $FILTER_TALKS_TEST_SRC

FILTER_TALKS_TEST_TGT=$WORKING_DIR/ted_${SRC_LANG}-${TGT_LANG}.test.${TGT_LANG}.xml
perl $SCRIPTS_DIR/filter-talks.pl \
    --talkids $OUTPUT_FILE_TEST \
    --xml-file $TGT_XML_FILE > $FILTER_TALKS_TEST_TGT

############################
### ted-extract-par.pl   ###
############################

# Extract parallel sentences:

# training:
PARSENT_OUT_TRAIN_SRC=$WORKING_DIR/ted_train_${SRC_LANG}-${TGT_LANG}.${SRC_LANG}
PARSENT_OUT_TRAIN_TGT=$WORKING_DIR/ted_train_${SRC_LANG}-${TGT_LANG}.${TGT_LANG}
PARSENT_OUT_TRAIN_DC=$WORKING_DIR/ted_train_${SRC_LANG}-${TGT_LANG}.discarded
perl $SCRIPTS_DIR/ted-extract-par.pl \
        --xmlsource $FILTER_TALKS_TRAIN_SRC \
        --xmltarget $FILTER_TALKS_TRAIN_TGT \
        --outsource $PARSENT_OUT_TRAIN_SRC \
        --outtarget $PARSENT_OUT_TRAIN_TGT \
        --outdiscarded $PARSENT_OUT_TRAIN_DC \
        --filter 1.96

# in case you are interested in keeping metadata on talks, activate the option "--tags"

# test:

PARSENT_OUT_TEST_SRC=$WORKING_DIR/ted_test_${SRC_LANG}-${TGT_LANG}.${SRC_LANG}
PARSENT_OUT_TEST_TGT=$WORKING_DIR/ted_test_${SRC_LANG}-${TGT_LANG}.${TGT_LANG}
PARSENT_OUT_TEST_DC=$WORKING_DIR/ted_test_${SRC_LANG}-${TGT_LANG}.discarded
perl $SCRIPTS_DIR/ted-extract-par.pl \
        --xmlsource $FILTER_TALKS_TEST_SRC \
        --xmltarget $FILTER_TALKS_TEST_TGT \
        --outsource $PARSENT_OUT_TEST_SRC \
        --outtarget $PARSENT_OUT_TEST_TGT \
        --outdiscarded $PARSENT_OUT_TEST_DC \
        --filter 1.96

############################
### ted-extract-mono.pl  ###
############################

# Extract monolingual text:

TED_TRAIN_TGT_NOXML=$WORKING_DIR/ted_train.${TGT_LANG}
perl $SCRIPTS_DIR/ted-extract-mono.pl \
        --xml $TED_TRAIN_TGT \
        --out $TED_TRAIN_TGT_NOXML

############################
###   rebuild-sent.pl    ###
############################

# Rebuild sentences on strong punctuation

# training:

perl $SCRIPTS_DIR/rebuild-sent.pl \
    --file-l1 $PARSENT_OUT_TRAIN_SRC \
    --file-l2 $PARSENT_OUT_TRAIN_TGT

# (now parallel rebuilt sentences are in 
#	working_dir/ted_train_en-de.(fen|de).sent
# files)


# test:

perl $SCRIPTS_DIR/rebuild-sent.pl \
    --file-l1 $PARSENT_OUT_TEST_SRC \
    --file-l2 $PARSENT_OUT_TEST_TGT


# monolingual:

cp $TED_TRAIN_TGT_NOXML $WORKING_DIR/__tmp__$$

perl $SCRIPTS_DIR/rebuild-sent.pl \
    --file-l1 $TED_TRAIN_TGT_NOXML \
    --file-l2 $WORKING_DIR/__tmp__$$

rm $WORKING_DIR/__tmp__$$*

############################
###       cleaning       ###
############################

# Some cleaning of the text would be recommended. For example, very
# roughly all stuff in brackets could be removed, since they are
# typically used for reporting extra linguistic phenomena like
# (Laughter), (Applause), (Music), (Video), etc.

SENT_TRAIN_SRC=$WORKING_DIR/ted_train_${SRC_LANG}-${TGT_LANG}.${SRC_LANG}.sent
SENT_TRAIN_TGT=$WORKING_DIR/ted_train_${SRC_LANG}-${TGT_LANG}.${TGT_LANG}.sent
SENT_CLEAN_TRAIN_SRC=$WORKING_DIR/ted_train_${SRC_LANG}-${TGT_LANG}.${SRC_LANG}.sent.clean
SENT_CLEAN_TRAIN_TGT=$WORKING_DIR/ted_train_${SRC_LANG}-${TGT_LANG}.${TGT_LANG}.sent.clean
cat $SENT_TRAIN_SRC | \
    perl -pe 's/\([^\)]+\)//g' > $SENT_CLEAN_TRAIN_SRC
cat $SENT_TRAIN_TGT | \
    perl -pe 's/\([^\)]+\)//g' > $SENT_CLEAN_TRAIN_TGT

SENT_TEST_SRC=$WORKING_DIR/ted_test_${SRC_LANG}-${TGT_LANG}.${SRC_LANG}.sent
SENT_TEST_TGT=$WORKING_DIR/ted_test_${SRC_LANG}-${TGT_LANG}.${TGT_LANG}.sent
SENT_CLEAN_TEST_SRC=$WORKING_DIR/ted_test_${SRC_LANG}-${TGT_LANG}.${SRC_LANG}.sent.clean
SENT_CLEAN_TEST_TGT=$WORKING_DIR/ted_test_${SRC_LANG}-${TGT_LANG}.${TGT_LANG}.sent.clean

cat $SENT_TEST_SRC | \
    perl -pe 's/\([^\)]+\)//g' > $SENT_CLEAN_TEST_SRC
cat $SENT_TEST_TGT | \
    perl -pe 's/\([^\)]+\)//g' > $SENT_CLEAN_TEST_TGT

TED_TRAIN_TGT_SENT=$WORKING_DIR/ted_train.${TGT_LANG}.sent
TED_TRAIN_TGT_SENT_CLEAN=$WORKING_DIR/ted_train.${TGT_LANG}.sent.clean
cat $TED_TRAIN_TGT_SENT | \
    perl -pe 's/\([^\)]+\)//g' > $TED_TRAIN_TGT_SENT_CLEAN

# More tricky cleaning is up to you!

############################
###     finalizing       ###
############################

SENT_CLEAN_TRAIN_SRC=$WORKING_DIR/ted_train_${SRC_LANG}-${TGT_LANG}.${SRC_LANG}.sent.clean
SENT_CLEAN_TRAIN_TGT=$WORKING_DIR/ted_train_${SRC_LANG}-${TGT_LANG}.${TGT_LANG}.sent.clean

mv $SENT_CLEAN_TRAIN_SRC $OUTPUT_DIR/ted_train_${SRC_LANG}-${TGT_LANG}.${SRC_LANG}
mv $SENT_CLEAN_TRAIN_TGT $OUTPUT_DIR/ted_train_${SRC_LANG}-${TGT_LANG}.${TGT_LANG}

mv $SENT_CLEAN_TEST_SRC $OUTPUT_DIR/ted_test_${SRC_LANG}-${TGT_LANG}.${SRC_LANG}
mv $SENT_CLEAN_TEST_TGT $OUTPUT_DIR/ted_test_${SRC_LANG}-${TGT_LANG}.${TGT_LANG}

mv $TED_TRAIN_TGT_SENT_CLEAN $OUTPUT_DIR/ted_train.${TGT_LANG}

rm -Rf $WORKING_DIR

###########################
###   rename things     ###
###########################
mkdir -p $OUTPUT_DIR/final
cat $OUTPUT_DIR/ted_train_${SRC_LANG}-${TGT_LANG}.${SRC_LANG} $OUTPUT_DIR/ted_test_${SRC_LANG}-${TGT_LANG}.${SRC_LANG} >> $OUTPUT_DIR/final/train.${SRC_LANG}
cat $OUTPUT_DIR/ted_train_${SRC_LANG}-${TGT_LANG}.${TGT_LANG} $OUTPUT_DIR/ted_test_${SRC_LANG}-${TGT_LANG}.${TGT_LANG} >> $OUTPUT_DIR/final/train.${TGT_LANG}
rm $OUTPUT_DIR/*
mv $OUTPUT_DIR/final/* $OUTPUT_DIR
rm -R $OUTPUT_DIR/final
