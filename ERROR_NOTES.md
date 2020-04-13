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

