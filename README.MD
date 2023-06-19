# EthereumFoundaryExamples

# FOUNDARY

### Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust. it is a toolkit for building decentralized applications.it consist of testing framework like Hardhat, truffle and Dapptools.

 <br>

 ## foundry provide three tools
 ### forge ==> used to deploy,compile and format the code

 ### cast ==> it also used to interact with contract that have been already deployed

 ### anvil ==> to spin up the local blockchain, forking the mainnet etc.
 <br>

## how to download foundary with forge library

 <li>
 
 <ul> If you use Windows, you need to build from source to get Foundry.</ul>

<ul> Download and run rustup-init from rustup.rs. It will start the installation in a console.</ul>

<ul> After this, run the following to build Foundry from source:</ul>

<ul>cargo install --git https://github.com/foundry-rs/foundry foundry-cli anvil --bins --locked </ul>

<ul>

now create a new project with forge init "projectname"

</ul>
 
 
 </li>
 <br>
 <br>

## file structure

#### it has src folder which contains main solidity code

#### it has test folder which contains test solidity code by running the each code that is import in it

#### script folder from this folder we will deploy our code on onchain or on local node

<br>

## to compile code

#### forge compile ==> will generate abi also

## how to run and test code

#### to run the code in test we first create ABI using "forge build" that will compile our code and generate ABI file

#### then we can run the code in test folder using "forge build"

#### test folder import code from src folder

<br>

## start local Node

### if you want to deploy smartcontract in local network you need to start local node using "anvil" command.

#### after running of node. deploy the smartcontract that is present in src/nameOfcontract from script folder by using command

## deploy contract directly from src folder using 

#### ```forge create SimpleStorage --rpc-url localhost:8545 --interactive``` it will ask for private key

## If we have script to deploye contract then use this below given command will not actual deploy the contract. it will just give the idea how much gas fee will be used to deploy this contract

<li>forge script script/filename.sol:smartcontractname --fork-url http://localhost:8545 --private-key "jksfhwjfo2iu8r947yr9o3n5v3t9ng2" </li>
<br>

#### if we want to deploy the contract then add --broadcast flag in the end

<li> forge script script/filename.sol:ContractScript --fork-url http://localhost:8545 --private-key jdhsikfhowp;sjf;wifjpwofjhwfow --broadcast --private-key anyPrivateKey

### call deployed contract with function that dont cost gas fee

<li>cast call contractaddress "function to call()(type of output)"</li> 
<br>

### if we want to call that function that cost some gas fee. we will use command. cast send always use when some data is updated in smartcontract

<li> cast send addressofcontract "functionwewanttocall()" --private-key

### this is used to call the function when contract are deployed onchain

cast call 0x354e3a1ebffbb055e797ea33883738baf49e4f05 "funcitonName" --rpc-url rpc_url

### convert hex to decimal using cast

### ``` cast --to-base 0x00000000000000000000000000000000000000000000000000000000000001ca dec```

### to override the chain id during forking mainnet use this. block number need to mention is required

<li> anvil --fork-url mainnet --fork-chain-id 1337 --fork-block-number 17194050 </li>r


## format the soldiity code

### run ```forge fmt``` in terminal 
