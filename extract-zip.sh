OUTPUT_PATH=$(pwd)/xml
cd zip
for f in *.zip;
do
    unzip $f -d $OUTPUT_PATH
done
