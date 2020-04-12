python=$(which python)
src=en
tgt=$1
exp_dir=$HOME/lmm-data/$src-$tgt
opennmt=$LMM_REPO
model_path=$2
gpu_device=$3

$python $opennmt/translate.py \
    -model "${model_path}" \
    -src_data_type words \
    -tgt_data_type characters \
    -src "${exp_dir}/test.${src}" \
    -output "${exp_dir}/test.output.${src}" \
    -gpu $gpu_device
