#!/bin/sh

# Prepares TED corpora for all of Ataman et al (2020)'s experiments
# Written by Jonne Saleva, 2020

SCRIPTS_PATH=$1
TED_PATH=$2
SRC_LANG=en

for TGT_LANG in ar cs tr
do
    $SCRIPTS_PATH/strip-ted-xml.sh ${SRC_LANG} ${TGT_LANG} ${SCRIPTS_PATH} ${TED_PATH}
done
