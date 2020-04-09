#!/bin/sh

# Convenience wrapper for tokenization in Moses 
# Jonne Saleva, 2020

TOKENIZER_SCRIPT=$MOSES_SCRIPTS/tokenizer/tokenizer.perl
LANGUAGE=$1
INPUT_FILE=$2
OUTPUT_FILE=$3

$TOKENIZER_SCRIPT \
    -l $LANGUAGE \
    < $INPUT_FILE \
    > $OUTPUT_FILE

