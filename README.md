# Pizza-Delivery NLP Hackathon

In this hackathon, I built an ASR system capable of recognize speech in the form of a set of audio recordings of people placing pizza orders and transcriptions of those recordings. I calculate the word error rate (WER) of a baseline system and try to improve the WER by modifying the pronunciation and language models.

![Pizza-Delivery-Picture](images/pizzaASR.png)

My two submission files include: 

* your best performing language model (`best.lm`)
* your best performing lexicon (`best.dic`)

Final submissions are tested on a separate test set of recordings and transcriptions that is similar but not identical to the development set given. 

## Results

Starting with my results, I was able to secure 1st place in this competition with the lowest WER of **9.33%**

Take a look at [my results journal](ResultsJournal.pdf) to see the notes on how I arrived at this winning score!


*Acknowledgement: This lab uses materials generously shared by Prof. Alan Black of Carnegie Mellon University.*


## Setup and Description

## Part 1: Install the required data and tools

### 1.1 Installation (Linux or Mac)
After cloning, follow these commands:
      
```
      cd Pizza-Delivery-ASR
      tar zxf pocketsphinx-0.5-20080912.tar.gz
      cd pocketsphinx-0.5
      ./build_all_static.sh
      cd ../h2
      ../pocketsphinx-0.5/pocketsphinx/scripts/setup_sphinx.pl -task rm     
```

### 2.2 Description of Audio Samples (Pronunciation Model)

The recordings to be recognized consist of requests for a specific size of pizza with one or more toppings. Each request can optionally start with one of the following phrases:

* I'd like to order a ...
* I want to order a ...
*  Give me a ...

This is followed by the size of pizza requested, either "small", "medium", "large", or "extra large", the word "pizza", and an optional list of toppings. The available toppings are: extra cheese, mushrooms, onions, black olives, green olives, pineapple, green peppers, broccoli, tomatoes, spinach, anchovies, sausage, pepperoni, ham, bacon

### 2.3 N-gram Language Model (a.k.a. "grammar")

A large sample of representative text is generated through my make_corpus.py file. Using a bit of linguistic knowledge, this file is able to procedurally generate many sentences to be used to train our model.


Build a trigram language model:

```
      perl quick_lm.pl -s baseline.corpus    
```    

This will create a language model file called `baseline.corpus.lm` and a lexicon called `baseline.corpus.dic`.

## Part 3: Run the baseline system

The baseline system can be run with

```
    bin/pocketsphinx_batch baseline.cfg     
```

If recognition was successful, you should see a lot of output on the screen, ending with a few lines like this (with different numbers):

```
INFO: batch.c(386): TOTAL 409.99 seconds speech, 10.60 seconds CPU, 10.67 seconds wall
INFO: batch.c(388): AVERAGE 0.03 xRT (CPU), 0.03 xRT (elapsed)
``` 
## Part 4: Testing your recognizer

The recognition results can now be found in the file `pizza_devel.hyp`. We now compute the word error rate (WER), which is the standard method for evaluating speech recognition systems. The script `word_align.pl` in the `scripts_pl/decode` directory compares the reference transcription to the recognition results and reports the error rate for each sentence, followed by the overall error rate. It can be run like this:

```
    perl scripts_pl/decode/word_align.pl etc/pizza_devel.transcription pizza_devel.hyp     
```

The final three lines of its output will report the number of errors and the error rate over the whole set of sentences decoded.

There are other words in the lexicon that can have multiple pronunciations, depending on personal preference, rate of speech, or dialect. Some additional pronunciations were added to the lexicon file to improve our model.

```
    bin/pocketsphinx_batch baseline.cfg     
    perl scripts_pl/decode/word_align.pl etc/pizza_devel.transcription pizza_devel.hyp     
```
