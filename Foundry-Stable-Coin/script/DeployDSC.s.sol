// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {DscEngine} from "../src/DscEngine.sol";
import {DecentralisedStableCoin} from "../src/DecentralisedStableCoin.sol";

contract DeployDSCScript is Script {
    DscEngine dscEnginedeploy;
    DecentralisedStableCoin decentralisedStableCoin;

    function run() external returns (DscEngine, DecentralisedStableCoin) {
        vm.startBroadcast();
        dscEnginedeploy = new DscEngine();
        decentralisedStableCoin = new DecentralisedStableCoin();
        vm.stopBroadcast();
        return (dscEnginedeploy, decentralisedStableCoin);
    }
}
