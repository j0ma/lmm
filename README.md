# A Latent Morphology Model for Open-Vocabulary Neural Machine Translation (fork)

My own fork of *Latent Morphology Model for Open-Vocabulary Neural Machine Translation* by D. Ataman
 
### Notes
- Using `subword-nmt` from Sennrich's group for the BPE learning
- Going to use `moses` for tokenization/truecasing
    - Always make sure `$MOSES_SCRIPTS` is set to point to the folder containing Moses' perl scripts
- BPE for English can be learned
    - a) Separately for each EN-TGT pair
    - b) Jointly from all EN training data
- Make sure to set the `$LMM_REPO` environment variable to point to the repository
    - There is now a check for this in `preprocess.sh`
- Make sure to use python 3.6 or earlier since 3.7 gives an odd error message about StopIteration
    - Alternatively you can go dig in the source code but it's probably easier to just 
t
### Notes about versions etc.

- this repo is based on open-nmt version: unknown
    - based on the repo structure & some diffing against different versions of OpenNMT-py, this is no later than 
- torchtext version: 0.2.1, 0.5.0

This is based on sasha's response [here](https://github.com/OpenNMT/OpenNMT-py/issues/767) after I observed an error relating to `tensor_type` with newer version than 0.2.1

To reproduce: using torchtext 0.5.0 & pytorch 1.4.0

```
Variable "gpu_device_id" not set, defaulting to gpu_device_id=0
Traceback (most recent call last):
  File "/home/ubuntu/lmm/train.py", line 430, in <module>
    main()
  File "/home/ubuntu/lmm/train.py", line 408, in main
    fields = load_fields(first_dataset, src_data_type, tgt_data_type, checkpoint)
  File "/home/ubuntu/lmm/train.py", line 325, in load_fields
    torch.load(opt.data + '.vocab.pt'), src_data_type)
  File "/home/ubuntu/lmm/onmt/io/IO.py", line 60, in load_fields_from_vocab
    fields = get_fields(data_type, n_src_features, n_tgt_features)
  File "/home/ubuntu/lmm/onmt/io/IO.py", line 46, in get_fields
    return TextDataset.get_fields(n_src_features, n_tgt_features)
  File "/home/ubuntu/lmm/onmt/io/TextDataset.py", line 221, in get_fields
    postprocessing=make_src, sequential=False)
TypeError: __init__() got an unexpected keyword argument 'tensor_type'
```

Switching to torchtext 0.2.1 gives an error of tensor shapes:

```
Variable "gpu_device_id" not set, defaulting to gpu_device_id=0
/home/ubuntu/anaconda3/lib/python3.6/site-packages/torch/nn/modules/rnn.py:50: UserWarning: dropout option adds dropout after all but last recurrent layer, so non-zero dropout expects num_layers greater than 1, but got dropout=0.2 and num_layers=1
  "num_layers={}".format(dropout, num_layers))
/home/ubuntu/anaconda3/lib/python3.6/site-packages/torch/nn/_reduction.py:43: UserWarning: size_average and reduce args will be deprecated, please use reduction='sum' instead.
  warnings.warn(warning.format(ret))
Traceback (most recent call last):
  File "/home/ubuntu/lmm/train.py", line 430, in <module>
    main()
  File "/home/ubuntu/lmm/train.py", line 422, in main
    train_model(model, fields, optim, src_data_type, tgt_data_type, model_opt)
  File "/home/ubuntu/lmm/train.py", line 240, in train_model
    train_stats = trainer.train(train_iter, epoch, report_func)
  File "/home/ubuntu/lmm/onmt/Trainer.py", line 179, in train
    report_stats, normalization)
  File "/home/ubuntu/lmm/onmt/Trainer.py", line 340, in _gradient_accumulation
    self.model(src, tgt, src_lengths, batch.batch_size, dec_state)
  File "/home/ubuntu/anaconda3/lib/python3.6/site-packages/torch/nn/modules/module.py", line 532, in __call__
    result = self.forward(*input, **kwargs)
  File "/home/ubuntu/lmm/onmt/Models.py", line 1259, in forward
    memory_lengths=lengths)
  File "/home/ubuntu/anaconda3/lib/python3.6/site-packages/torch/nn/modules/module.py", line 532, in __call__
    result = self.forward(*input, **kwargs)
  File "/home/ubuntu/lmm/onmt/Models.py", line 802, in forward
    tgt, memory_bank, batch_size, state, memory_lengths=memory_lengths, translate=False)
  File "/home/ubuntu/lmm/onmt/Models.py", line 1090, in _run_forward_pass
    word_rep = self.wordcomposition(torch.cat([z, f], dim=1))
RuntimeError: invalid argument 0: Sizes of tensors must match except in dimension 1. Got 5 and 64 in dimension 0 at /pytorch/aten/src/THC/generic/THCTensorMath.cu:71
```

If I downgrade to PyTorch 1.1.0, I get the same error.

If I downgrade to PyTorch 0.4.0, I get a new error about `Tensor.unbind()`:

```
Traceback (most recent call last):
  File "/home/ubuntu/lmm/train.py", line 430, in <module>
    main()
  File "/home/ubuntu/lmm/train.py", line 422, in main
    train_model(model, fields, optim, src_data_type, tgt_data_type, model_opt)
  File "/home/ubuntu/lmm/train.py", line 240, in train_model
    train_stats = trainer.train(train_iter, epoch, report_func)
  File "/home/ubuntu/lmm/onmt/Trainer.py", line 179, in train
    report_stats, normalization)
  File "/home/ubuntu/lmm/onmt/Trainer.py", line 340, in _gradient_accumulation
    self.model(src, tgt, src_lengths, batch.batch_size, dec_state)
  File "/home/ubuntu/anaconda3/lib/python3.6/site-packages/torch/nn/modules/module.py", line 491, in __call__
    result = self.forward(*input, **kwargs)
  File "/home/ubuntu/lmm/onmt/Models.py", line 1243, in forward
    tgt1 = torch.cat(tgt1.unbind(2), dim=1)
AttributeError: 'Tensor' object has no attribute 'unbind'
```

If I downgrade to PyTorch 0.3.1, I get a TypeError:

```
Traceback (most recent call last):
  File "/home/ubuntu/lmm/train.py", line 430, in <module>
    main()
  File "/home/ubuntu/lmm/train.py", line 422, in main
    train_model(model, fields, optim, src_data_type, tgt_data_type, model_opt)
  File "/home/ubuntu/lmm/train.py", line 240, in train_model
    train_stats = trainer.train(train_iter, epoch, report_func)
  File "/home/ubuntu/lmm/onmt/Trainer.py", line 164, in train
    for i, batch in enumerate(train_iter):
  File "/home/ubuntu/lmm/train.py", line 143, in __iter__
    for batch in self.cur_iter:
  File "/home/ubuntu/lmm/onmt/io/Wordbatch.py", line 329, in __iter__
    self.train)
  File "/home/ubuntu/lmm/onmt/io/Wordbatch.py", line 169, in __init__
    idx_batch = [torch.cat([torch.tensor([[2,2]+[1]*(x.size(0)-2)]).transpose(0,1).cuda(), x], dim=1) for x in idx_batch]
  File "/home/ubuntu/lmm/onmt/io/Wordbatch.py", line 169, in <listcomp>
    idx_batch = [torch.cat([torch.tensor([[2,2]+[1]*(x.size(0)-2)]).transpose(0,1).cuda(), x], dim=1) for x in idx_batch]
TypeError: 'module' object is not callable
```

Earlier versions of `pytorch` fail to pip install with various kinds of runtime errors.

### Todo

- [x] host dataset somewhere
- [x] write `download-data.sh` to download and extract TED xml
- [x] write tokenization/lowercasing/truecasing/BPE scripts
    - [x] tokenization of src/tgt
    - [x] truecasing model for each lang pair
    - [x] bpe of english target side
- [x] preprocess corpus into correct format
    - [x] TED dataset
    - [x] IWSLT dataset
- [] get `examples/train.sh` working
- [] get `examples/translate.sh` working

--- 

This software implements the Neural Machine Translation model based on Hierchical Character-based Decoding using Variational Inference.

## Options

### Hiearchical Decoder with Compositional Word Embeddings and Character-level Generation with Variational Inference 

  To activate the character-level decoder, select

  ```-tgt_data_type characters``` in the settings of preprocess.py and translate.py 

  and

  ```-decoder_type charrnn``` and ```-tgt_data_type characters```  in train.py
  
  The feature dimensions are hardcoded to 100 for the lemma and 10 for inflectional feature vectors, you can change this depending on your language or data size.

## Further information

For information about how to install and use OpenNMT-py:
[Full Documentation](http://opennmt.net/OpenNMT-py/)


## Citation

If you use this software, please cite:
@article{lmm,
  author    = {Duygu Ataman and
               Wilker Aziz and
               Alexandra Birch},
  title     = {A Latent Morphology Model for Open-Vocabulary Neural Machine Translation},
  booktitle = {Under Review as Conference Paper at ICLR},
  year      = {2019},
}
```
