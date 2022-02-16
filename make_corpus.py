# 
# Simple sentence builder for a corpus file
# Robert/RJ Smithers
# 

import random, sys

NUM_SENTENCES = 2
if len(sys.argv) > 1:
    NUM_SENTENCES = int(sys.argv[1])

start = "<s> "
end = "</s>"
empty = ""

first = ["I'd like to order ", "I'd like ", "I want to order ", "I want ", "I wanna ", "I wanna order ", "Give me ", "Gimme "]
second = ["a small pizza ", "a medium pizza ", "a large pizza ", "an extra large pizza "]
third = [end, "with "]
fourth = [empty, "extra "]
fifth = ["cheese ", "mushrooms ", "onions ", "black olives ", "green olives ", "pineapple ", "green peppers ", "hot peppers ", "broccoli ", "tomatoes ", "spinach ", "anchovies ", "sausage ", "pepperoni ", "ham ", "bacon "]
sixth = ["and ", "for pickup ", "for delivery ", empty]


# Weights should be an array with weights between 0 and 1 for each index
def random_index(li, weights=[]):
    ran = random.choice(range(0, 101))/100.0
    for i in range(0, len(weights)):
        if (ran < weights[i] + sum(weights[:i])):
            return li[i]
    return random.choice(li)

def construct_sentence():
    sentence, next_word = "", ""
    sentence += start
    sentence += str(random_index(first)).upper()
    sentence += str(random_index(second, weights=[0.3, 0.3, 0.3, 0.1])).upper()
    
    next_word = random_index(third, weights=[0.05, 0.95])
    if next_word == end:
        sentence += next_word
        return sentence
    
    sentence += str(next_word).upper()
    
    while (True):   # And topping, and topping, and topping (weighted)... for delivery/for pickup/""
        sentence += str(random_index(fourth, weights=[0.80, 0.2])).upper()
        sentence += str(random_index(fifth)).upper()
        next_word = str(random_index(sixth, weights=[0.5, 0.1, 0.1, 0.3])).upper()
        if (not next_word == "AND "):
            sentence += next_word + end
            return sentence
        sentence += next_word


for i in range(0, NUM_SENTENCES):
    print(construct_sentence())
