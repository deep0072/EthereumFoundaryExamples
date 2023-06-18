// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

import "../src/GasLessTokenTransfer.sol";

contract GasLessTokenTransferScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        console.log(deployerPrivateKey, "private_key");
        vm.startBroadcast(deployerPrivateKey);
        GasLessTokenTransfer gaslesscontract = new GasLessTokenTransfer();

        vm.stopBroadcast();
    }
}
