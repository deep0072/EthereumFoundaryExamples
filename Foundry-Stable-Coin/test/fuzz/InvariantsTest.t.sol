// SPDX-License-Identifier: MIT

// get invraints from th contract which will not change throught out the contract

// 1. total supply of dsc coin should be less than the toatalvalue of collateral

// 2. Getter View functions should never revert

pragma solidity ^0.8.19;

import {StdInvariant} from "forge-std/StdInvariant.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployDSCScript} from "../../script/DeployDSC.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DecentralisedStableCoin} from "../../src/DecentralisedStableCoin.sol";
import {DscEngine} from "../../src/DscEngine.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract InvariantTest is StdInvariant, Test {
    DeployDSCScript deployerDsc;
    DecentralisedStableCoin dscCoin;
    HelperConfig helperConfig;
    DscEngine dscEngine;
    address wETH;
    address wBTC;

    function setUp() external {
        deployerDsc = new DeployDSCScript();
        (dscEngine, dscCoin, helperConfig) = deployerDsc.run();
        targetContract(address(dscEngine));
        (wETH, wBTC,,,) = helperConfig.ActiveNetworkConfig();
    }

    function invariant_protocolMustHaveMpreValueThanTotalSupply() external {
        // first get total supply
        // get the total weth and wBTC deposited
        // ans then get value in usd of both weth and wBTC

        uint256 totalSupply = dscCoin.totalSupply();
        uint256 totalWeth = IERC20(wETH).balanceOf(address(dscEngine));
        uint256 totalWbtc = IERC20(wBTC).balanceOf(address(dscEngine));
        uint256 wethValueInUsd =
            dscEngine.getColletralValueInUsd(totalWeth, wETH);
        uint256 wBtcValueInUsd =
            dscEngine.getColletralValueInUsd(totalWbtc, wBTC);
        console.log(totalSupply, "totalSupply");

        uint256 totalCollateralValue = wethValueInUsd + wBtcValueInUsd;
        console.log(totalCollateralValue, "totalCollateralValue");
        assert(totalCollateralValue >= totalSupply);
    }
}
