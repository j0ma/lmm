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
