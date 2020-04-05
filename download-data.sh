# download-data.sh

if [ -z $TEDPATH ];
then
    TEDPATH=$HOME"/ted_datasets"
fi

echo $TEDPATH

# Downloads the TED corpora along with processing tools
