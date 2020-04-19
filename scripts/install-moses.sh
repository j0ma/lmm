#!/bin/sh
# install-moses.sh 
REPO_URL="https://github.com/moses-smt/mosesdecoder"
MOSES_DEPS_URL="https://j0ma.keybase.pub/moses-dependencies.txt"

# clone moses
git clone $REPO_URL $HOME/mosesdecoder

# install dependencies
echo "Installing dependencies..."
MOSES_DEPS=$(curl -s $MOSES_DEPS_URL)
for prog in $MOSES_DEPS
do
    sudo apt-get install $prog
done

# cd into moses
cd $HOME/mosesdecoder

# build 
./bjam -j4

# run for the first time
wget http://www.statmt.org/moses/download/sample-models.tgz
tar xzf sample-models.tgz
cd sample-models
cd ~/mosesdecoder/sample-models
~/mosesdecoder/bin/moses -f phrase-model/moses.ini < phrase-model/in > out
cat out
rm out

