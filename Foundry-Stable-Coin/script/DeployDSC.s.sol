// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {DscEngine} from "../src/DscEngine.sol";
import {DecentralisedStableCoin} from "../src/DecentralisedStableCoin.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployDSCScript is Script {
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function run() external returns (DscEngine, DecentralisedStableCoin) {
        HelperConfig helperConfig = new HelperConfig();
        (address wETH, address wBTC, address wEthPriceFeed, address wBtcPriceFeed, uint256 deployerKey) =
            helperConfig.ActiveNetworkConfig();

        tokenAddresses = [wETH, wBTC];
        priceFeedAddresses = [wEthPriceFeed, wBtcPriceFeed];
        vm.startBroadcast(deployerKey);

        DecentralisedStableCoin dsc = new DecentralisedStableCoin();
        DscEngine dscEnginedeploy = new DscEngine(tokenAddresses,priceFeedAddresses,address(dsc));

        // now transfer the ownership of the dsc contract to dscEngine contract
        dsc.transferOwnership(address(dscEnginedeploy));
        vm.stopBroadcast();

        return (dscEnginedeploy, dsc);
    }
}
