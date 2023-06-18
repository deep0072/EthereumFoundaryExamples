// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract DeploySimpleStorage is Script {
    /*
    he run() function is the entry point of the script. 
    It is marked as external to allow 
    it to be called from outside the contract.    
    */

    function run() external returns (SimpleStorage) {
        /*The vm.startBroadcast() ==>function is a special cheat code provided by the Foundry standard library. It starts a broadcast, 
        indicating that the following logic should 
        take place on-chain.*/
        vm.startBroadcast();
        SimpleStorage simpleStorage = new SimpleStorage();

        /**
         *
         * The vm.stopBroadcast() function ends the broadcast,
         * indicating that the on-chain logic is complete.
         *
         */
        vm.stopBroadcast();
        return simpleStorage;
    }
}
