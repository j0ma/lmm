#!/bin/sh

SCRIPTS_PATH=$1
ROOT_FOLDER=$2
SRC_LANG=$3
TGT_LANG=$4

cd "${ROOT_FOLDER}/${SRC_LANG}-${TGT_LANG}"

# tokenize training dev and test set
for kind in train dev test
do
    $SCRIPTS_PATH/moses-tokenize.sh \
        $SRC_LANG \
        "${kind}/${kind}.${SRC_LANG}" \
        "${kind}/${kind}.tok.${SRC_LANG}"

    $SCRIPTS_PATH/moses-tokenize.sh \
        $TGT_LANG \
        "${kind}/${kind}.${TGT_LANG}" \
        "${kind}/${kind}.tok.${TGT_LANG}"
done 

# train truecaser on train set
$SCRIPTS_PATH/moses-train-truecaser.sh \
    "${TGT_LANG}-truecaser.model" \
    "train/train.tok.${TGT_LANG}"

$SCRIPTS_PATH/moses-train-truecaser.sh \
    "${SRC_LANG}-truecaser.model" \
    "train/train.tok.${SRC_LANG}"

# truecase train dev and test set
for kind in train dev test
do
    $SCRIPTS_PATH/moses-truecase.sh \
        "${TGT_LANG}-truecaser.model" \
        "${kind}/${kind}.tok.${TGT_LANG}" \
        "${kind}/${kind}.tok.true.${TGT_LANG}"

    $SCRIPTS_PATH/moses-truecase.sh \
        "${SRC_LANG}-truecaser.model" \
        "${kind}/${kind}.tok.${SRC_LANG}" \
        "${kind}/${kind}.tok.true.${SRC_LANG}"
done 

