# RANDOM RAFFLE SMART CONTRACTS

## About

this code is to create a random smart contract lottery. Decentralization will be at peak in this project. no biased selection

## what we want to do

1.Users can enter by paying for a ticket
<br>

2.after x period of time . the lottery will automatically draw a winner and fee collected as entry fee will be give to the winner. all will be done programmetically.
<br>

3. we use chainLink VRF and chainLink Automation
    1. chainLink VRF ==> for randomness
    2. chainLink Automation ==> time based trigger (time stamp)

### chainLikn Vrf ==>

1. this contract we will first call ```requestRandomWords``  that will help us to get the random number

2. then requestRandom words call ```fulfillRandomWords()``` function which is inherited from ```VRFConsumerBaseV2``` which gives the response of random word. 

<br>

### chainLink Automation ==>

1. this contract let us our contract's functions to trigger after specifc period of time.

2. here we will use two functions 
    a.) checkUpKeep ==> This function is responsible for checking if the upkeep (in this case, triggering the your function  function) is needed. It will be called periodically to determine if the x-minute interval has passed since the last time the  function was triggered

    b.)performUpKeep ==>  function actually triggers the your function when the checkUpkeep function determines that it is needed.

