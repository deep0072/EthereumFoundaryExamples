// SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 1 ether;

    function fundfundMe(address mostRecentDeployment) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployment)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();

        console.log("funded amount is %s", SEND_VALUE);
    }

    function run() external {
        // grab the address of most recent deployed contract here
        address mostRecentlyDeployed =
            DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        fundfundMe(mostRecentlyDeployed);
    }
}

contract WithdrawFundMe is Script {
    uint256 constant SEND_VALUE = 1 ether;

    function withdrawFundMe(address mostRecentDeployment) public {
        FundMe(payable(mostRecentDeployment)).withDraw();
    }

    function run() external {
        // grab the address of most recent deployed contract here
        address mostRecentlyDeployed =
            DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();

        withdrawFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}
