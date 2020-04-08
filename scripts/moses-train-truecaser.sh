#!/bin/sh

# Convenience wrapper for training a truecaser in Moses
# Jonne Saleva, 2020

TRUECASE_TRAINING_SCRIPT=$MOSES_SCRIPTS/recaser/train-truecaser.perl
MODEL_FILE=$1
TOKENIZED_CORPUS_FILE=$2

$TRUECASE_TRAINING_SCRIPT \
    --model $MODEL_FILE \
    --corpus $TOKENIZED_CORPUS_FILE

