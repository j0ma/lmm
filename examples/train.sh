#!/bin/sh

if [ -z $LMM_REPO ]
then
    echo "Environment variable LMM_REPO not set!"
    echo "Be sure to make it point to the LMM repository"
    echo "before running train.sh"
    exit 1
fi

python=$(which python)
src=en
tgt=$1
exp_dir=$HOME/lmm-data/$src-$tgt
opennmt=$LMM_REPO

num_epochs=200

$python $opennmt/train.py \
    -data $exp_dir/iwslt \
    -epochs $num_epochs \
    -word_vec_size 512 \
    -enc_layers 1 \
    -dec_layers 1 \
    -seed 1234 \
    -rnn_size 512 \
    -rnn_type GRU \
    -encoder_type birnn \
    -decoder_type charrnn \
    -tgt_data_type characters \
    -optim adam \
    -learning_rate 0.0003 \
    -learning_rate_decay 0.9 \
    -dropout 0.2 \
    -start_decay_at $num_epochs \
    -start_checkpoint_at 5 \
    -save_model $exp_dir/model \
    -gpu 1 \
    -gpuid 1 \
    -max_grad_norm 1 > log.out

