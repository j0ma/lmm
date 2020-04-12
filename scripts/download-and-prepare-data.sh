#!/bin/sh

# download-data.sh

BPE_SIZE=16000

# Downloads the TED & IWSLT corpora
SCRIPTS_PATH="$(pwd)/scripts"
TRAINING_DATA_ARCHIVE="ted-datasets-lmm.zip"
TRAINING_CORPUS_URL="https://j0ma.keybase.pub/datasets/${TRAINING_DATA_ARCHIVE}"
DEVTEST_DATA_ARCHIVE="iwslt-datasets-lmm.zip"
DEVTEST_CORPUS_URL="https://j0ma.keybase.pub/datasets/${DEVTEST_DATA_ARCHIVE}"

if [ -z $DATA_PATH ];
then
    DATA_PATH=$HOME"/lmm-data"
fi

TRAIN_PATH=$DATA_PATH/train
DEVTEST_PATH=$DATA_PATH/devtest
mkdir -p $TRAIN_PATH
mkdir -p $DEVTEST_PATH

cd $TRAIN_PATH
echo "Downloading compresed training corpus if needed..."
if [ -z $(ls | grep "${TRAINING_DATA_ARCHIVE}") ]
then
    wget $TRAINING_CORPUS_URL
    #cp /tmp/$TRAINING_DATA_ARCHIVE .
else
    echo "Compressed corpus exists! No need to download."
fi

echo "Extracting XML files from archives..."
$SCRIPTS_PATH/extract-ted.sh $TRAIN_PATH

echo "Creating parallel text training data from TED XML corpus..."
$SCRIPTS_PATH/prepare-ted-all.sh $SCRIPTS_PATH $TRAIN_PATH
cd ..

cd $DEVTEST_PATH
echo "Downloading compresed dev/test corpus if needed..."
if [ -z $(ls | grep "${DEVTEST_DATA_ARCHIVE}") ]
then
    wget $DEVTEST_CORPUS_URL
    #cp /tmp/$DEVTEST_DATA_ARCHIVE .
else
    echo "Compressed corpus exists! No need to download."
fi

echo "Creating parallel text dev/test data from IWLST corpus..."
$SCRIPTS_PATH/prepare-iwslt-all.sh \
    $DEVTEST_PATH/$DEVTEST_DATA_ARCHIVE \
    $DEVTEST_PATH $SCRIPTS_PATH

cd ..

echo "Performing final moves to make sure directory structure is right..."
SRC=en
for TGT in ar cs tr
do
    SRC_TGT=${SRC}-${TGT}
    mkdir ./$SRC_TGT
    mv train/$SRC_TGT/* ./$SRC_TGT
    mv devtest/$SRC_TGT/* ./$SRC_TGT
done
rm -Rf train
rm -Rf devtest


echo "Applying preprocessing steps with Moses (tokenization, truecasing, ...)"
for TGT in ar cs tr
do
    $SCRIPTS_PATH/moses/moses-preprocessing-all.sh \
        "${SCRIPTS_PATH}/moses" $DATA_PATH $SRC $TGT
done

echo "Learning & applying BPE with subword-nmt..."
for TGT in ar cs tr
do
    $SCRIPTS_PATH/bpe-preprocessing-all.sh \
        $DATA_PATH $SRC $TGT $BPE_SIZE
done

echo "Download and processing complete!"
tree $DATA_PATH || ls -l $DATA_PATH
