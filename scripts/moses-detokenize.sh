#!/bin/sh

# Convenience wrapper for detokenization in Moses 
# Jonne Saleva, 2020

DETOKENIZER_SCRIPT=$MOSES_SCRIPTS/tokenizer/detokenizer.perl
LANGUAGE=$1
INPUT_FILE=$2
OUTPUT_FILE=$3

$DETOKENIZER_SCRIPT \
    -q -l $LANGUAGE \
    < $INPUT_FILE \
    > $OUTPUT_FILE

