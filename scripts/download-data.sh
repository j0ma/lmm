#!/bin/sh

# download-data.sh

# Downloads the TED corpora along with processing tools
SCRIPTS_PATH="$(pwd)/scripts"
ARCHIVE_NAME="ted-datasets-lmm.zip"
CORPUS_URL="https://j0ma.keybase.pub/datasets/${ARCHIVE_NAME}"

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

echo "Download and processing complete!"
tree $TED_PATH || ls -l $TED_PATH
