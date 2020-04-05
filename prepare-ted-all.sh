#!/bin/sh

# Prepares TED corpora for all of Ataman et al (2020)'s experiments
# Written by Jonne Saleva, 2020

SRC_LANG=en

for TGT_LANG in ar cs tr
do
    sh prepare-ted-single-pair.sh ${SRC_LANG} ${TGT_LANG}
done
