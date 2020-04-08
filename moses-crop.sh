#!/bin/sh

# Convenience wrapper for cropping sentences up to MAXLENGTH
# Jonne Saleva, 2020

CROPPING_SCRIPT=$MOSES_SCRIPTS/training/clean-corpus-n.perl

TRUECASE_PREFIX=$1
SRC_LANG=$2
TGT_LANG=$3
CLEAN_PREFIX=$4
MIN_SIZE=$5

if [ -z $MIN_SIZE ]
then
    MIN_SIZE=1
fi

MAX_SIZE=$6
if [ -z $MAX_SIZE ]
then
    MAX_SIZE=80
fi

$CROPPING_SCRIPT $TRUECASE_PREFIX $SRC_LANG $TGT_LANG $CLEAN_PREFIX $MIN_SIZE $MAX_SIZE
    

