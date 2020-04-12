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

### Todo

- [x] host dataset somewhere
- [x] write `download-data.sh` to download and extract TED xml
- [] write tokenization/lowercasing/truecasing/BPE scripts
    - [] tokenization of src/tgt
    - [] truecasing model for each lang pair
    - [] bpe of english target side
- [] preprocess corpus into correct format
    - [x] TED dataset
    - [] IWSLT dataset

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
