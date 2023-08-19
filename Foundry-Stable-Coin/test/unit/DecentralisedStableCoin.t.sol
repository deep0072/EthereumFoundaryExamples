// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {DeployDSCScript} from "../../script/DeployDSC.s.sol";
import {DscEngine} from "../../src/DscEngine.sol";
import {DecentralisedStableCoin} from "../../src/DecentralisedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract DecentralisedStableCoinTest is Test {
    DeployDSCScript dscEngineDeployer;
    DscEngine dscEngine;
    DecentralisedStableCoin dscCoin;
    HelperConfig config;
    address wETH;
    address wEthPriceFeed;

    uint256 constant STARTING_BALANCE = 100 ether;
    uint256 constant COLLATERAL_AMOUNT = 10 ether;
    address public USER = makeAddr("Deepak");

    function setUp() public {
        dscEngineDeployer = new DeployDSCScript();
        (dscEngine, dscCoin, config) = dscEngineDeployer.run();
        (wETH,, wEthPriceFeed,,) = config.ActiveNetworkConfig();
        ERC20Mock(wETH).mint(USER, STARTING_BALANCE);
    }

    ////////////////////////////////////////////////////////////////
    ///// price test //////////////////////////////////////////////
    //////////////////////////////////////////////////////////////
    function testgetColletralValueInUsd() public {
        uint256 tokenAmount = 15e18;

        uint256 expectedValue = 30000e18;
        console.log(wEthPriceFeed, "wEthPriceFeed");
        console.log(wETH, "wEth");

        uint256 actualValue =
            dscEngine.getColletralValueInUsd(tokenAmount, wETH);
        assertEq(actualValue, expectedValue);
    }

    ////////////////////////////////
    // depositCollateral Tests /////
    ////////////////////////////////
    function testRevertIfCollateralIsZero() public {
        // first create user
        // give some weth to the user by minintg coin using "erc20mock"

        vm.startPrank(USER);
        // then approve the dscengine contract to spend token of user
        ERC20Mock(wETH).approve(address(dscEngine), COLLATERAL_AMOUNT);

        vm.expectRevert(DscEngine.DscEngine__amountShouldMoreThanZero.selector);
        // then call depositCollateral function

        dscEngine.depositCollateral(wETH, 0);
        vm.stopPrank();
    }

    function testredeemCollateral() public {
        vm.startPrank(USER);

        dscEngine.redeemCollateral(0, wETH);
        vm.stopPrank();
    }
}
