# A useful loop for adding training data etc.

```
cd ...trainable-tokenizer/installation
export PATH=$PATH:$(pwd)/trtok/
source $(pwd)/config.sh
# manually modify whatever is needed from ../models/schemes/*
# esp. search *tok for various inconsistenticies

# then update the "installed" schemes with the modified official ones
rm -rf trtok/schemes; make trtok/schemes

# and test it on a particular *training* file:
f=trtok/schemes/czeng/cs/training_data/KA_06_27-part2
trtok tokenize czeng/cs -r /txt/testout/ $f.txt
vimdiff $f.testout $f.tok
```
