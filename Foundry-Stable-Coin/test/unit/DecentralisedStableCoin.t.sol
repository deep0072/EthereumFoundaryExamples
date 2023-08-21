// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {DeployDSCScript} from "../../script/DeployDSC.s.sol";
import {DscEngine} from "../../src/DscEngine.sol";
import {DecentralisedStableCoin} from "../../src/DecentralisedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";
import {AggregatorV3Interface} from
    "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {MockV3Aggregator} from "../mock/MockV3Aggregator.sol";

contract DecentralisedStableCoinTest is Test {
    event CollateralRedeemed(
        address indexed redeemFrom,
        address indexed redeemTo,
        address token,
        uint256 amount
    ); // if redeemFrom != redeemedTo, th

    DeployDSCScript dscEngineDeployer;
    DscEngine dscEngine;
    DecentralisedStableCoin dscCoin;
    HelperConfig config;
    address wETH;
    address wBTC;
    address wEthPriceFeed;
    address wBtcPriceFeed;

    uint256 constant STARTING_BALANCE = 100 ether;
    uint256 constant COLLATERAL_AMOUNT = 10 ether;
    address public USER = makeAddr("Deepak");
    uint256 constant ADDITIONAL_PRECISION = 1e10;
    uint256 constant PRECISION = 1e18;
    uint256 amountToMint = 100 ether;
    uint256 public constant MIN_HEALTH_FACTOR = 1e18;
    uint256 public constant LIQUIDATION_THRESHOLD = 50;

    // Liquidation
    address public liquidator = makeAddr("liquidator");
    uint256 public collateralToCover = 20 ether;

    function setUp() public {
        dscEngineDeployer = new DeployDSCScript();
        (dscEngine, dscCoin, config) = dscEngineDeployer.run();
        (wETH, wBTC, wEthPriceFeed, wBtcPriceFeed,) =
            config.ActiveNetworkConfig();
        ERC20Mock(wETH).mint(USER, STARTING_BALANCE);
    }

    ////////////////////////////////////////////////////////////////
    ///// construcotor test //////////////////////////////////////////////
    //////////////////////////////////////////////////////////////
    address[] public tokenAddress;
    address[] public priceFeedAddress;

    function testRevertIfTokenLengthDoesnotMatchPriceFeed() public {
        tokenAddress.push(wETH);
        priceFeedAddress.push(wEthPriceFeed);
        priceFeedAddress.push(wBtcPriceFeed);

        vm.expectRevert(
            DscEngine.DscEngine__tokenAndPriceFeedArrayArenotSame.selector
        );
        new DscEngine(tokenAddress,priceFeedAddress,address(dscCoin));
    }

    ////////////////////////////////////////////////////////////////
    ///// price test //////////////////////////////////////////////
    //////////////////////////////////////////////////////////////
    function testgetColletralValueInUsd() public {
        uint256 tokenAmount = 15e18;

        uint256 expectedValue = 30000e18;
        console.log(wEthPriceFeed, "wEthPriceFeed");
        console.log(wETH, "wETH");

        uint256 actualValue =
            dscEngine.getColletralValueInUsd(tokenAmount, wETH);
        assertEq(actualValue, expectedValue);
    }

    function testtokenAmountFromUsd() public {
        uint256 expectedEth = 2e18;
        uint256 amountOfUSdInWei = 4000e18;

        uint256 actualEth = dscEngine.getTokenfromUsd(wETH, amountOfUSdInWei);
        console.log(actualEth, "actualEth");
        assertEq(expectedEth, actualEth);
    }

    ////////////////////////////////
    // depositCollateral Tests /////
    ////////////////////////////////
    function testRevertIfCollateralIsZero() public {
        // first create USER
        // give some wETH to the USER by minintg coin using "erc20mock"

        vm.startPrank(USER);
        // then approve the dscengine contract to spend token of USER
        ERC20Mock(wETH).approve(address(dscEngine), COLLATERAL_AMOUNT);

        vm.expectRevert(DscEngine.DscEngine__amountShouldMoreThanZero.selector);
        // then call depositCollateral function

        dscEngine.depositCollateral(wETH, 0);
        vm.stopPrank();
    }

    function testRevertsIfUnaaprovedCollateralTokenDeposit() public {
        // first create that collateral
        ERC20Mock deepToken =
            new ERC20Mock("Deepak coin", "DC", USER,COLLATERAL_AMOUNT );

        vm.startPrank(USER);
        vm.expectRevert(DscEngine.DscEngine__tokenNotAllowed.selector);
        dscEngine.depositCollateral(address(deepToken), COLLATERAL_AMOUNT);
        vm.stopPrank();
    }

    modifier depositCollateral(address user) {
        vm.startPrank(user);
        //first need to approve the spender to spend coin on the USER behalf
        ERC20Mock(wETH).approve(address(dscEngine), COLLATERAL_AMOUNT);

        // then dscEngine will able to deposit the collateral in contact

        dscEngine.depositCollateral(wETH, COLLATERAL_AMOUNT);
        vm.stopPrank();
        _;
    }

    function testCanDepositCollateralAndGetAccountInfo()
        public
        depositCollateral(USER)
    {
        (uint256 mintedDsc, uint256 collateralValueINUSd) =
            dscEngine.getAccountInfo(USER);

        uint256 expectedTokenAmount =
            dscEngine.getTokenfromUsd(wETH, collateralValueINUSd);

        uint256 expectedMintedDsc = 0;

        assertEq(COLLATERAL_AMOUNT, expectedTokenAmount);
        assertEq(expectedMintedDsc, mintedDsc);
    }

    ///////////////////////////////////////
    // depositCollateralAndMintDsc Tests //
    ///////////////////////////////////////

    function testRevertsIfCollateralZero() public {
        vm.startPrank(USER);
        ERC20Mock(wETH).approve(address(dscEngine), COLLATERAL_AMOUNT);

        vm.expectRevert(DscEngine.DscEngine__amountShouldMoreThanZero.selector);
        dscEngine.depositCollateral(wETH, 0);
        vm.stopPrank();
    }

    function testRevertsWithUnapprovedCollateral() public {
        ERC20Mock randToken = new ERC20Mock("RAN", "RAN", USER, 100e18);
        vm.startPrank(USER);
        vm.expectRevert(
            abi.encodeWithSelector(
                DscEngine.DscEngine__tokenNotAllowed.selector, address(randToken)
            )
        );
        dscEngine.depositCollateral(address(randToken), COLLATERAL_AMOUNT);
        vm.stopPrank();
    }

    modifier depositedCollateral() {
        vm.startPrank(USER);
        ERC20Mock(wETH).approve(address(dscEngine), COLLATERAL_AMOUNT);
        dscEngine.depositCollateral(wETH, COLLATERAL_AMOUNT);
        vm.stopPrank();
        _;
    }

    function testCanDepositCollateralWithoutMinting()
        public
        depositedCollateral
    {
        uint256 userBalance = dscCoin.balanceOf(USER);
        assertEq(userBalance, 0);
    }

    function testCanDepositedCollateralAndGetAccountInfo()
        public
        depositedCollateral
    {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) =
            dscEngine.getAccountInfo(USER);
        uint256 expectedDepositedAmount =
            dscEngine.getTokenfromUsd(wETH, collateralValueInUsd);
        assertEq(totalDscMinted, 0);
        assertEq(expectedDepositedAmount, COLLATERAL_AMOUNT);
    }

    ///////////////////////////////////////
    // depositCollateralAndMintDsc Tests //
    ///////////////////////////////////////

    function testRevertsIfMintedDscBreaksHealthFactor() public {
        (, int256 price,,,) = MockV3Aggregator(wEthPriceFeed).latestRoundData();
        amountToMint =
            (
                COLLATERAL_AMOUNT
                    * (uint256(price) * dscEngine.getAdditionalFeedPrecision())
            )
            / dscEngine.getPrecision();
        vm.startPrank(USER);
        ERC20Mock(wETH).approve(address(dscEngine), COLLATERAL_AMOUNT);

        uint256 expectedHealthFactor = dscEngine.calculateHealthFactor(
            amountToMint, dscEngine.getColletralValueInUsd(COLLATERAL_AMOUNT, wETH)
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                DscEngine.DscEngine__userHeathFactorIsBroken.selector, expectedHealthFactor
            )
        );
        dscEngine.depositCollateralAndMintDsc(
            wETH, COLLATERAL_AMOUNT, amountToMint
        );
        vm.stopPrank();
    }

    modifier depositedCollateralAndMintedDsc() {
        vm.startPrank(USER);
        ERC20Mock(wETH).approve(address(dscEngine), COLLATERAL_AMOUNT);
        dscEngine.depositCollateralAndMintDsc(
            wETH, COLLATERAL_AMOUNT, amountToMint
        );
        vm.stopPrank();
        _;
    }

    function testCanMintWithDepositedCollateral()
        public
        depositedCollateralAndMintedDsc
    {
        uint256 userBalance = dscCoin.balanceOf(USER);
        assertEq(userBalance, amountToMint);
    }

    ///////////////////////////////////
    // mintDsc Tests //
    ///////////////////////////////////
    // This test needs it's own custom setup

    function testRevertsIfMintAmountIsZero() public {
        vm.startPrank(USER);
        ERC20Mock(wETH).approve(address(dscEngine), COLLATERAL_AMOUNT);
        dscEngine.depositCollateralAndMintDsc(
            wETH, COLLATERAL_AMOUNT, amountToMint
        );
        vm.expectRevert(DscEngine.DscEngine__amountShouldMoreThanZero.selector);
        dscEngine.mintDsc(0);
        vm.stopPrank();
    }

    function testRevertsIfMintAmountBreaksHealthFactor() public {
        // 0xe580cc6100000000000000000000000000000000000000000000000006f05b59d3b20000
        // 0xe580cc6100000000000000000000000000000000000000000000003635c9adc5dea00000
        (, int256 price,,,) = MockV3Aggregator(wEthPriceFeed).latestRoundData();
        amountToMint =
            (
                COLLATERAL_AMOUNT
                    * (uint256(price) * dscEngine.getAdditionalFeedPrecision())
            )
            / dscEngine.getPrecision();

        vm.startPrank(USER);
        ERC20Mock(wETH).approve(address(dscEngine), COLLATERAL_AMOUNT);
        dscEngine.depositCollateral(wETH, COLLATERAL_AMOUNT);

        uint256 expectedHealthFactor = dscEngine.calculateHealthFactor(
            amountToMint, dscEngine.getTokenfromUsd(wETH, COLLATERAL_AMOUNT)
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                DscEngine.DscEngine__userHeathFactorIsBroken.selector, expectedHealthFactor
            )
        );
        dscEngine.mintDsc(amountToMint);
        vm.stopPrank();
    }

    function testCanMintDsc() public depositedCollateral {
        vm.prank(USER);
        dscEngine.mintDsc(amountToMint);

        uint256 userBalance = dscCoin.balanceOf(USER);
        assertEq(userBalance, amountToMint);
    }

    ///////////////////////////////////
    // burnDsc Tests //
    ///////////////////////////////////

    function testRevertsIfBurnAmountIsZero() public {
        vm.startPrank(USER);
        ERC20Mock(wETH).approve(address(dscEngine), COLLATERAL_AMOUNT);
        dscEngine.depositCollateralAndMintDsc(
            wETH, COLLATERAL_AMOUNT, amountToMint
        );
        vm.expectRevert(DscEngine.DscEngine__amountShouldMoreThanZero.selector);
        dscEngine.burnDsc(0);
        vm.stopPrank();
    }

    function testCantBurnMoreThanUserHas() public {
        vm.prank(USER);
        vm.expectRevert();
        dscEngine.burnDsc(1);
    }

    function testCanBurnDsc() public depositedCollateralAndMintedDsc {
        vm.startPrank(USER);
        dscCoin.approve(address(dscEngine), amountToMint);
        dscEngine.burnDsc(amountToMint);
        vm.stopPrank();

        uint256 userBalance = dscCoin.balanceOf(USER);
        assertEq(userBalance, 0);
    }

    ///////////////////////////////////
    // redeemCollateral Tests //
    //////////////////////////////////

    function testRevertsIfRedeemAmountIsZero() public {
        vm.startPrank(USER);
        ERC20Mock(wETH).approve(address(dscEngine), COLLATERAL_AMOUNT);
        dscEngine.depositCollateralAndMintDsc(
            wETH, COLLATERAL_AMOUNT, amountToMint
        );
        vm.expectRevert(DscEngine.DscEngine__amountShouldMoreThanZero.selector);
        dscEngine.redeemCollateral(0, wETH);
        vm.stopPrank();
    }

    function testCanRedeemCollateral() public depositedCollateral {
        vm.startPrank(USER);
        dscEngine.redeemCollateral(COLLATERAL_AMOUNT, wETH);
        uint256 userBalance = ERC20Mock(wETH).balanceOf(USER);
        assertEq(userBalance, COLLATERAL_AMOUNT);
        vm.stopPrank();
    }

    function testEmitCollateralRedeemedWithCorrectArgs()
        public
        depositedCollateral
    {
        vm.expectEmit(true, true, true, true, address(dscEngine));
        emit CollateralRedeemed(USER, USER, wETH, COLLATERAL_AMOUNT);
        vm.startPrank(USER);
        dscEngine.redeemCollateral(COLLATERAL_AMOUNT, wETH);
        vm.stopPrank();
    }

    ///////////////////////////////////
    // redeemCollateralForDsc Tests //
    //////////////////////////////////

    function testMustRedeemMoreThanZero()
        public
        depositedCollateralAndMintedDsc
    {
        vm.startPrank(USER);
        dscCoin.approve(address(dscEngine), amountToMint);
        vm.expectRevert(DscEngine.DscEngine__amountShouldMoreThanZero.selector);
        dscEngine.redeemCollateralForDsc(wETH, 0, amountToMint);
        vm.stopPrank();
    }

    function testCanRedeemDepositedCollateral() public {
        vm.startPrank(USER);
        ERC20Mock(wETH).approve(address(dscEngine), COLLATERAL_AMOUNT);
        dscEngine.depositCollateralAndMintDsc(
            wETH, COLLATERAL_AMOUNT, amountToMint
        );
        dscCoin.approve(address(dscEngine), amountToMint);
        dscEngine.redeemCollateralForDsc(wETH, COLLATERAL_AMOUNT, amountToMint);
        vm.stopPrank();

        uint256 userBalance = dscCoin.balanceOf(USER);
        assertEq(userBalance, 0);
    }

    ////////////////////////
    // healthFactor Tests //
    ////////////////////////

    function testProperlyReportsHealthFactor()
        public
        depositedCollateralAndMintedDsc
    {
        uint256 expectedHealthFactor = 100 ether;
        uint256 healthFactor = dscEngine.checkUserHealthFactor(USER);
        // $100 minted with $20,000 collateral at 50% liquidation threshold
        // means that we must have $200 collatareral at all times.
        // 20,000 * 0.5 = 10,000
        // 10,000 / 100 = 100 health factor
        assertEq(healthFactor, expectedHealthFactor);
    }

    function testHealthFactorCanGoBelowOne()
        public
        depositedCollateralAndMintedDsc
    {
        int256 ethUsdUpdatedPrice = 18e8; // 1 ETH = $18
        // Rememeber, we need $150 at all times if we have $100 of debt

        MockV3Aggregator(wEthPriceFeed).updateAnswer(ethUsdUpdatedPrice);

        uint256 userHealthFactor = dscEngine.checkUserHealthFactor(USER);
        // $180 collateral / 200 debt = 0.9
        assert(userHealthFactor == 0.9 ether);
    }

    ///////////////////////
    // Liquidation Tests //
    ///////////////////////

    // This test needs it's own setup

    function testCantLiquidateGoodHealthFactor()
        public
        depositedCollateralAndMintedDsc
    {
        ERC20Mock(wETH).mint(liquidator, collateralToCover);

        vm.startPrank(liquidator);
        ERC20Mock(wETH).approve(address(dscEngine), collateralToCover);
        dscEngine.depositCollateralAndMintDsc(
            wETH, collateralToCover, amountToMint
        );
        dscCoin.approve(address(dscEngine), amountToMint);

        vm.expectRevert(DscEngine.DscEngine__HealthFactorIsOk.selector);
        dscEngine.liquidate(wETH, USER, amountToMint);
        vm.stopPrank();
    }

    modifier liquidated() {
        vm.startPrank(USER);
        ERC20Mock(wETH).approve(address(dscEngine), COLLATERAL_AMOUNT);
        dscEngine.depositCollateralAndMintDsc(
            wETH, COLLATERAL_AMOUNT, amountToMint
        );
        vm.stopPrank();
        int256 ethUsdUpdatedPrice = 18e8; // 1 ETH = $18

        MockV3Aggregator(wEthPriceFeed).updateAnswer(ethUsdUpdatedPrice);
        uint256 userHealthFactor = dscEngine.checkUserHealthFactor(USER);

        ERC20Mock(wETH).mint(liquidator, collateralToCover);

        vm.startPrank(liquidator);
        ERC20Mock(wETH).approve(address(dscEngine), collateralToCover);
        dscEngine.depositCollateralAndMintDsc(
            wETH, collateralToCover, amountToMint
        );
        dscCoin.approve(address(dscEngine), amountToMint);
        dscEngine.liquidate(wETH, USER, amountToMint); // We are covering their whole debt
        vm.stopPrank();
        _;
    }

    function testLiquidationPayoutIsCorrect() public liquidated {
        uint256 liquidatorWethBalance = ERC20Mock(wETH).balanceOf(liquidator);
        uint256 expectedWeth = dscEngine.getTokenfromUsd(wETH, amountToMint)
            +
            (
                dscEngine.getTokenfromUsd(wETH, amountToMint)
                    / dscEngine.getLiquidationBonus()
            );
        uint256 hardCodedExpected = 6111111111111111110;
        assertEq(liquidatorWethBalance, hardCodedExpected);
        assertEq(liquidatorWethBalance, expectedWeth);
    }

    function testUserStillHasSomeEthAfterLiquidation() public liquidated {
        // Get how much wETH the USER lost
        uint256 amountLiquidated = dscEngine.getTokenfromUsd(wETH, amountToMint)
            +
            (
                dscEngine.getTokenfromUsd(wETH, amountToMint)
                    / dscEngine.getLiquidationBonus()
            );

        uint256 usdAmountLiquidated =
            dscEngine.getTokenfromUsd(wETH, amountLiquidated);
        uint256 expectedUserCollateralValueInUsd =
            dscEngine.getTokenfromUsd(
                wETH, COLLATERAL_AMOUNT
            )
            - (usdAmountLiquidated);

        (, uint256 userCollateralValueInUsd) = dscEngine.getAccountInfo(USER);
        uint256 hardCodedExpectedValue = 70000000000000000020;
        assertEq(userCollateralValueInUsd, expectedUserCollateralValueInUsd);
        assertEq(userCollateralValueInUsd, hardCodedExpectedValue);
    }

    function testLiquidatorTakesOnUsersDebt() public liquidated {
        (uint256 liquidatorDscMinted,) =
            dscEngine.getAccountInfo(liquidator);
        assertEq(liquidatorDscMinted, amountToMint);
    }

    function testUserHasNoMoreDebt() public liquidated {
        (uint256 userDscMinted,) = dscEngine.getAccountInfo(USER);
        assertEq(userDscMinted, 0);
    }

    ///////////////////////////////////
    // View & Pure Function Tests //
    //////////////////////////////////
    function testGetCollateralTokenPriceFeed() public {
        address priceFeed = dscEngine.getCollateralTokenPriceFeed(wETH);
        assertEq(priceFeed, wEthPriceFeed);
    }

    function testGetCollateralTokens() public {
        address[] memory collateralTokens = dscEngine.getCollateralTokens();
        assertEq(collateralTokens[0], wETH);
    }

    function testGetMinHealthFactor() public {
        uint256 minHealthFactor = dscEngine.getMinHealthFactor();
        assertEq(minHealthFactor, MIN_HEALTH_FACTOR);
    }

    function testGetLiquidationThreshold() public {
        uint256 liquidationThreshold = dscEngine.getLiquidationThreshold();
        assertEq(liquidationThreshold, LIQUIDATION_THRESHOLD);
    }

    function testGetAccountCollateralValueFromInformation()
        public
        depositedCollateral
    {
        (, uint256 collateralValue) = dscEngine.getAccountInfo(USER);
        uint256 expectedCollateralValue =
            dscEngine.getTokenfromUsd(wETH, COLLATERAL_AMOUNT);
        assertEq(collateralValue, expectedCollateralValue);
    }

    function testGetCollateralBalanceOfUser() public {
        vm.startPrank(USER);
        ERC20Mock(wETH).approve(address(dscEngine), COLLATERAL_AMOUNT);
        dscEngine.depositCollateral(wETH, COLLATERAL_AMOUNT);
        vm.stopPrank();
        uint256 collateralBalance =
            dscEngine.getCollateralBalanceOfUser(USER, wETH);
        assertEq(collateralBalance, COLLATERAL_AMOUNT);
    }

    function testGetAccountCollateralValue() public {
        vm.startPrank(USER);
        ERC20Mock(wETH).approve(address(dscEngine), COLLATERAL_AMOUNT);
        dscEngine.depositCollateral(wETH, COLLATERAL_AMOUNT);
        vm.stopPrank();
        uint256 collateralValue = dscEngine.getAccountCollateralValue(USER);
        uint256 expectedCollateralValue =
            dscEngine.getTokenfromUsd(wETH, COLLATERAL_AMOUNT);
        assertEq(collateralValue, expectedCollateralValue);
    }

    function testGetDsc() public {
        address dscAddress = dscEngine.getDsc();
        assertEq(dscAddress, address(dscCoin));
    } // function testInvariantBreaks() public depositedCollateralAndMintedDsc {
} //     MockV3Aggregator(wEthPriceFeed).updateAnswer(0);
    //     uint256 wethDeposted = ERC20Mock(wETH).balanceOf(address(dscEngine));
    //     uint256 wbtcDeposited = ERC20Mock(wbtc).balanceOf(address(dscEngine));
    //     uint256 wbtcValue = dscEngine.getTokenfromUsd(wbtc, wbtcDeposited);
    //     console.log("wbtcValue: %s", wbtcValue);
    //     console.log("totalSupply: %s", totalSupply);
    // }
// How do we adjust our invariant tests for this?
//     uint256 totalSupply = dsc.totalSupply();
//     uint256 wethValue = dscEngine.getTokenfromUsd(wETH, wethDeposted);
//     console.log("wethValue: %s", wethValue);
//     assert(wethValue + wbtcValue >= totalSupply);
