ROOT_PATH=$1
OUTPUT_PATH=${ROOT_PATH}/ted-raw

mkdir -p ${OUTPUT_PATH}

# extract big zip file
BIGZIP=$(ls ${ROOT_PATH}/*.zip | head -1) 
unzip $BIGZIP -d $OUTPUT_PATH

cd ${OUTPUT_PATH}/zip
for f in *.zip;
do
    unzip $f -d $OUTPUT_PATH
done
