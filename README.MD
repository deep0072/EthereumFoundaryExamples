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

### when we run forge test. foundry then let run anvil the local chain default after execution anvil stop the chain.
#### to run the code in the test we first create ABI using "forge build" which will compile our code and generate ABI file

#### Then we can run the code in the test folder using "forge build"

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


<br>

# foundry cheatcodes

### vm.prank(user) ==> used to set msg.sender all line below this will be execute by the address it self

### vm.expectRevert() ==> this cheatcode used for failed test condition. just write the code for failing condtion then that code succeeded without the error.

### vm.deal(user, balanceOf eth) ==> used to provide eth balance  to the address.

### vm.startBroadcast() ==> this is used to deploy the contract on chain.

### hoax(addressOF ,eth_amount) ==> it works both of vm.prank and vm.deal


### vm.txGasPrice(gasPrice); ==> it is used to set gasPrice. by default anvil set the gas price to zero.

#### Tells the VM to start recording all the emitted events.
```vm.recordLogs()``` 

#### to access the recorded events or logs
```vm.getRecordedLogs```

here is the snippet how to access the recorded events

```
/// event LogCompleted(
/// uint256 indexed topic1,
/// bytes data
/// );
vm.recordLogs();
emit LogCompleted(10, "operation completed");
Vm.Log[] memory entries = vm.getRecordedLogs();
assertEq(entries.length, 1);
assertEq(entries[0].topics[0], keccak256("LogCompleted(uint256,bytes)"));
assertEq(entries[0].topics[1], bytes32(uint256(10)));
assertEq(abi.decode(entries[0].data, (string)), "operation completed");
```
 
