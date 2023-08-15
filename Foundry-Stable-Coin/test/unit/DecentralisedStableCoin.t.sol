// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {DeployDSCScript} from "../../script/DeployDSC.s.sol";
import {DscEngine} from "../../src/DscEngine.sol";
import {DecentralisedStableCoin} from "../../src/DecentralisedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

// import "../src/Counter.sol";

contract DecentralisedStableCoinTest is Test {
    DeployDSCScript dscEngineDeployer;
    DscEngine dscEngine;
    DecentralisedStableCoin dscCoin;
    HelperConfig config;
    address wETH;
    address wEthPriceFeed;

    function setUp() public {
        dscEngineDeployer = new DeployDSCScript();
        (dscEngine, dscCoin) = dscEngineDeployer.run();
        (wETH,, wEthPriceFeed,,) = config.ActiveNetworkConfig();
    }

    function testgetColletralValueInUsd() public {
        uint256 tokenAmount = 15e18;
        uint256 expectedValue = 3000e18;
        console.log(wEthPriceFeed, "wEthPriceFeed");

        uint256 actualValue =
            dscEngine.getColletralValueInUsd(tokenAmount, wEthPriceFeed);

        console.log(actualValue, "actualValue");

        // assertEq(actualValue, expectedValue);
    }
}
