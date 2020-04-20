python=/home/ubuntu/miniconda3/envs/lmm/bin/python3.6
src=en
tgt=$1
exp_dir=$HOME/lmm-data/$src-$tgt
opennmt=$LMM_REPO
save_data_dir=$exp_dir/demo
save_model_dir=$exp_dir/model
log_file_name="${src}-${tgt}.train.log"
num_epochs=1

python --version

if [ -z $tgt ]
then
    echo "Must provide target language as command line argument!"
    exit 1
fi

if [ -z $LMM_REPO ]
then
    echo "Environment variable LMM_REPO not set!"
    echo "Be sure to make it point to the LMM repository"
    echo "before running train.sh"
    exit 1
fi

if [ -z $gpu_device_id ]
then
    echo "Variable \"gpu_device_id\" not set, defaulting to gpu_device_id=0"
    gpu_device_id=0
fi

$python $opennmt/train.py \
    -data $save_data_dir \
    -epochs $num_epochs \
    -word_vec_size 512 \
    -enc_layers 1 \
    -dec_layers 1 \
    -seed 1234 \
    -rnn_size 512 \
    -rnn_type GRU \
    -encoder_type brnn \
    -decoder_type charrnn \
    -tgt_data_type characters \
    -optim adam \
    -learning_rate 0.0003 \
    -learning_rate_decay 0.9 \
    -dropout 0.2 \
    -start_decay_at $num_epochs \
    -start_checkpoint_at 5 \
    -save_model $save_model_dir \
    -max_grad_norm 1 \
    -gpu $gpu_device_id \
    -gpuid $gpu_device_id > $log_file_name 
