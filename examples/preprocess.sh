#!/bin/sh

python=$(which python)
src=en
tgt=tr
exp_dir=$HOME/lmm-data/$src-$tgt
opennmt=$LMM_REPO
save_data_dir=$exp_dir/tmp-save

mkdir -p $save_data_dir

echo "Experiment dir: ${exp_dir}"
echo "Save data dir: ${save_data_dir}"

$python $opennmt/preprocess.py \
    -train_src "${exp_dir}/train/train.bpe.${src}" \
    -train_tgt "${exp_dir}/train/train.tok.true.${tgt}" \
    -valid_src "${exp_dir}/dev/dev.bpe.${src}" \
    -valid_tgt "${exp_dir}/dev/dev.tok.true.${tgt}" \
    -save_data "${save_data_dir}" \
    -src_data_type words \
    -tgt_data_type characters \
    -src_vocab_size 16005 \
    -tgt_vocab_size 1000 \
    -src_seq_length 200 \
    -tgt_seq_length 200
