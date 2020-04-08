#!/bin/sh

# Convenience wrapper for truecasing in Moses 
# Jonne Saleva, 2020

TRUECASE_TRAINING_SCRIPT=$MOSES_SCRIPTS/recaser/truecase.perl
MODEL_FILE=$1
INPUT_FILE=$2
OUTPUT_FILE=$3

$TRUECASE_TRAINING_SCRIPT \
    --model $MODEL_FILE \
    < $INPUT_FILE \
    > $OUTPUT_FILE

