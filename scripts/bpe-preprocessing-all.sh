#!/bin/sh

# bpe-preprocessing-all.sh
# Learns & applies BPE 

ROOT_FOLDER=$1
SRC_LANG=$2
TGT_LANG=$3
BPE_SIZE=$4
JOINT=$5

echo "Performing BPE on: ${SRC_LANG}-${TGT_LANG}"

cd "${ROOT_FOLDER}/${SRC_LANG}-${TGT_LANG}"
mkdir -p bpe

# learn bpe on tokenized & truecased training set for english
echo "Learning BPE for ${SRC_LANG}..."
TRAIN_FILE="train/train.tok.true.${SRC_LANG}"
CODES_FILE="bpe/${SRC_LANG}.bpe.codes"
if [ -z $JOINT ]
then
    subword-nmt learn-bpe -s $BPE_SIZE < $TRAIN_FILE > $CODES_FILE
else
    echo "Joint training-set BPE not implemented!"
    exit 1
fi

# apply bpe train dev test sets
for kind in train dev test
do
    echo "Applying BPE to ${kind} set..."
    INPUT_FILE="${kind}/${kind}.en"
    OUTPUT_FILE="${kind}/${kind}.bpe.en"
    subword-nmt apply-bpe -c $CODES_FILE < $INPUT_FILE > $OUTPUT_FILE
done

echo "All done!"
