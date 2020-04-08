#!/bin/sh

# download-data.sh

# Downloads the TED corpora along with processing tools
SCRIPTS_PATH="$(pwd)/scripts"
ARCHIVE_NAME="ted-datasets-lmm.zip"
CORPUS_URL="https://j0ma.keybase.pub/datasets/${ARCHIVE_NAME}"
BPESIZE=16000

if [ -z $TED_PATH ];
then
    TED_PATH=$HOME"/ted-datasets"
fi

echo "Creating folder ${TED_PATH}"
mkdir -p $TED_PATH
cd $TED_PATH

echo "Downloading compresed corpus if needed..."
if [ -z $(ls | grep "${ARCHIVE_NAME}") ]
then
    wget $CORPUS_URL
else
    echo "Compressed corpus exists at ${TED_PATH}/${ARCHIVE_NAME} ! No need to download."
fi

echo "Extracting XML files from archives..."
$SCRIPTS_PATH/extract-zip.sh $TED_PATH

echo "Creating parallel text from XML..."
$SCRIPTS_PATH/prepare-ted-all.sh $SCRIPTS_PATH $TED_PATH

echo "Applying preprocessing steps with Moses (tokenization, truecasing, ...)"
$SCRIPTS_PATH/moses-preprocessing-all.sh $SCRIPTS_PATH $TED_PATH

echo "Learning BPE with subword-nmt..."
$SCRIPTS_PATH/bpe-preprocessing-all.sh $SCRIPTS_PATH $TED_PATH $BPESIZE

echo "Download and processing complete!"
tree $TED_PATH || ls -l $TED_PATH
