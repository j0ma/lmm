python=$(which python)
src=en
tgt=tr
exp_dir=$HOME/lmm-data/$src-$tgt
opennmt=$(pwd)

echo "Experiment dir: ${exp_dir}"

$python $opennmt/preprocess.py \
    -train_src $exp_dir/train/train.$src \
    -train_tgt $exp_dir/train.$tgt \
    -valid_src $exp_dir/dev.$src \
    -valid_tgt $exp_dir/dev.$tgt \
    -save_data $exp_dir/iwslt \ 
    -src_data_type words \ 
    -tgt_data_type characters \
    -src_vocab_size 16005 \
    -tgt_vocab_size 1000 \
    -src_seq_length 200 \
    -tgt_seq_length 200
