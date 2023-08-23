// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "forge-std/console.sol";

import {DecentralisedStableCoin} from "./DecentralisedStableCoin.sol";

import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {OracleLib} from "./library/OracleLib.sol";

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title DSCEngine
 * @author  Deepak
 *
 * This token is designed to have the token maintain a 1 token == $1 pegged
 * This stable coin has properties:
 * Exogenous Collateral
 * our coin should be overcollateralised. means collateral value should not be lower than the  current dsc value.
 * Dollar pegged
 * Algorithmically stabled
 * similar to DAI if dai had no governance and no fee was only backed by wBtc ,wETH
 *
 * @notice This is the core of our system and handle all logic for mining and redeeming DSC as well as deposition and withdrawal of collateral
 */

contract DscEngine is ReentrancyGuard {
    //////////////////
    /// errors /////
    /////////////////

    error DscEngine__amountShouldMoreThanZero();
    error DscEngine__tokenAndPriceFeedArrayArenotSame();
    error DscEngine__tokenNotAllowed();
    error DscEngine__transferFailed();
    error DscEngine__userHeathFactorIsBroken(uint256 healthFactor);
    error DscEngine__mintingFailed();
    error DscEngine__HealthFactorIsOk();
    error DscEngine__HealthFactorIsNotImproved();

    //////////////////
    /// types /////
    /////////////////

    // this library first check collateral price is changing periodically within any time given,
    // if not then DscEngine will revert the process

    using OracleLib for AggregatorV3Interface;

    //////////////////
    ///state variable/////
    /////////////////

    mapping(address token => address priceFeedAddress) public s_priceFeed; // token address to priceFeed (weth/usd pair chainlINk priceFeedAddress)

    DecentralisedStableCoin private immutable i_dsc;

    uint256 private PRECISION_FEED = 1e18;
    uint256 private ADDITIONAL_PRECISION_FEED = 1e10;
    uint256 private constant PRECISION = 1e18;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;
    address[] private s_collateralTokens;
    mapping(address user => uint256 dscMinted) private s_DSCminted;
    uint256 private constant LIQUIDATION_THRESHHOLD = 50;
    uint256 private constant LIQUIDATION_PRECISION = 100;
    uint256 private constant MIN_HEALTH_FACTOR = 1e18;
    uint256 private constant LIQUIDATION_BONUS = 10;

    //////////////////
    ///events/////
    /////////////////

    event CollateralDeposited(address indexed user, address indexed tokenAddress, uint256 amount);
    event collateralRedeemed(
        address indexed from, address indexed to, address indexed tokenCollateralAddress, uint256 collateralAmount
    );

    //////////////////
    ///modifiers/////
    /////////////////

    modifier moreThanZero(uint256 amount) {
        if (amount <= 0) {
            revert DscEngine__amountShouldMoreThanZero();
        }
        _;
    }

    modifier isTokenAllowed(address tokenAddress) {
        if (s_priceFeed[tokenAddress] == address(0)) {
            revert DscEngine__tokenNotAllowed();
        }
        _;
    }

    //////////////////
    ///functions/////
    /////////////////

    constructor(address[] memory tokenAddress, address[] memory priceFeedAddresses, address dscAdress) {
        if (tokenAddress.length != priceFeedAddresses.length) {
            revert DscEngine__tokenAndPriceFeedArrayArenotSame();
        }
        for (uint256 i = 0; i < tokenAddress.length; i++) {
            s_priceFeed[tokenAddress[i]] = priceFeedAddresses[i];
            s_collateralTokens.push(tokenAddress[i]);
        }
        i_dsc = DecentralisedStableCoin(dscAdress);
    }

    //////////////////
    ///External functions/////
    /////////////////

    /*
     * @params tokenCollateralAddress is the address of token to deposit as collateral
     * @params collateralAmount is the amount to deposit collateral
     * @params amountDscToMint is amount of dsc coin we are going to mint
     * @notice this function is going to deposit and mint the collateral

       
    
    */
    function depositCollateralAndMintDsc(
        address tokenCollateralAddress,
        uint256 collateralAmount,
        uint256 amountDscToMint
    ) external {
        depositCollateral(tokenCollateralAddress, collateralAmount);
        mintDsc(amountDscToMint);
    }

    /*
     * @params tokenCollateralAddress is the address of token to deposit as collateral
     * @params collateralAmount is the amount to deposit collateral
       
    
    */
    function depositCollateral(address tokenCollateralAddress, uint256 collateralAmount)
        public
        moreThanZero(collateralAmount)
        isTokenAllowed(tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += collateralAmount;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, collateralAmount);

        // now transfer collateral to this contract
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), collateralAmount);

        if (!success) {
            revert DscEngine__transferFailed();
        }
    }

    /*
    * @param amountDscToMint==> amoun of decentralised stablecoin to min
    * @notice must have collateral value more thant the threshold 
    
     */
    function mintDsc(uint256 amountDscToMint) public moreThanZero(amountDscToMint) nonReentrant {
        s_DSCminted[msg.sender] += amountDscToMint;

        // check the minted Amount is more than the collateral amount or not
        _revertHealtFactorIsBroken(msg.sender);

        bool minted = i_dsc.mint(msg.sender, amountDscToMint);
        if (!minted) {
            revert DscEngine__mintingFailed();
        }
    }

    /**
     * @param tokenCollateralAddress is address of collateral that is about to be redeemed
     * @param amountOFCollateral is the amount of token
     * @param amountDscToBUrn these are the token that going to be burn
     * this function burn dsc and redeem collateral in one transaction
     */

    function redeemCollateralForDsc(address tokenCollateralAddress, uint256 amountOFCollateral, uint256 amountDscToBUrn)
        external
    {
        // first burn  and then redeem the collateral

        _burnDsc(amountDscToBUrn, msg.sender, msg.sender);

        _redeemCollateral(msg.sender, msg.sender, tokenCollateralAddress, amountOFCollateral);
    }

    /**
     * @notice this function is used to transfer your minted coin and the get your deposited coin from contract
     */

    function redeemCollateral(uint256 collateralAmount, address collateralAddress)
        external
        moreThanZero(collateralAmount)
        nonReentrant
    {
        _redeemCollateral(msg.sender, msg.sender, collateralAddress, collateralAmount);

        // now check heath factor

        _revertHealtFactorIsBroken(msg.sender);
    }

    /**
     * @notice function is used to burn minted coin when user redeem their coin
     */

    function burnDsc(uint256 mintedDscCoin) external moreThanZero(mintedDscCoin) {
        s_DSCminted[msg.sender] -= mintedDscCoin;

        // now transfer mintedDsc coin from msg.sender to this contract
        // transferfrom function let approve the dsc contract to spend the minted coin on the behalf of msg.sender
        // and the transfer the coin from msg.sender to this dscEngine contract
        _burnDsc(mintedDscCoin, msg.sender, msg.sender);

        _revertHealtFactorIsBroken(msg.sender);
    }

    /**
     * @param tokenCollateralAddress ==> collateral Address that about to get Liquidated
     * @param User ==> who has broken the health factor
     * @param debtToCOver ==> amount of token who will pay and get the collateral in return
     * @notice ==> function only works if protocol 200 % percent overcollateralised
     * @notice ==> user who will pay the debt amount will get bonus as a collateral for taking the user funds
     * @notice ==> if user (who broke the health factor) has underCollateralised debt then other user will not get the bonus
     *
     */
    function liquidate(address tokenCollateralAddress, address User, uint256 debtToCOver)
        external
        moreThanZero(debtToCOver)
        nonReentrant
    {
        uint256 startingHealthFactor = _checkUserHealthFactor(User);
        // need to check health factor first

        if (startingHealthFactor >= 1) {
            revert DscEngine__HealthFactorIsOk();
        }

        // as a liquidator we wanted to burn their dsc by depositing  our eth equivalent of burn amount
        // then take collateral equivalent of burn amount of eth plus the bonus
        // let say bad user = 140$ eth  and $100 dsc
        // deb to cover is $100 dsc that need to pay in eth as a liquidator
        // will get 100$ of eth or collateral and plus 10 percent of extra of the payment we made. total is 110$
        // 10 percent vary to protocol to protocol

        uint256 tokenAmountFromDebtToRecover = getTokenfromUsd(tokenCollateralAddress, debtToCOver);

        // now liquidator will also get the bonus lets say bonus will be 10 percent of tokenAmountFromDebtToRecover

        uint256 bonusCollateral = (tokenAmountFromDebtToRecover * 10) / PRECISION;

        uint256 totalCollateralRedeemed = tokenAmountFromDebtToRecover + bonusCollateral;

        // now call the redeemFunction
        _redeemCollateral(User, msg.sender, tokenCollateralAddress, totalCollateralRedeemed);

        // then burn the debttoRecover
        _burnDsc(tokenAmountFromDebtToRecover, User, msg.sender);

        uint256 endingHealthFactor = _checkUserHealthFactor(User);

        // then check healthFactor and

        if (endingHealthFactor <= startingHealthFactor) {
            revert DscEngine__HealthFactorIsNotImproved();
        }

        _revertHealtFactorIsBroken(msg.sender);
    }

    ////////////////////////////////////////////
    ///Internal and Private view functions//////
    ////////////////////////////////////////////

    function _redeemCollateral(address from, address to, address collateralAddress, uint256 amounOfCollateral)
        private
    {
        s_collateralDeposited[from][collateralAddress] -= amounOfCollateral;
        emit collateralRedeemed(from, to, collateralAddress, amounOfCollateral);

        bool success = IERC20(collateralAddress).transferFrom(from, to, amounOfCollateral);
        if (!success) {
            revert DscEngine__transferFailed();
        }
    }

    function _burnDsc(uint256 amountToBurn, address onTheBehalfOf, address from) private {
        s_DSCminted[onTheBehalfOf] -= amountToBurn;
        bool success = i_dsc.transferFrom(from, address(this), amountToBurn);
        if (!success) {
            revert DscEngine__transferFailed();
        }

        i_dsc.burn(amountToBurn);
    }

    function _revertHealtFactorIsBroken(address user) internal view {
        uint256 userHealthFactor = _checkUserHealthFactor(user);
        if (userHealthFactor <= MIN_HEALTH_FACTOR) {
            revert DscEngine__userHeathFactorIsBroken(userHealthFactor);
        }

        // check healthFactor (if they have enough collateral)
    }

    /* 
       * this contract will calcualte the collatralised amount 
       * on the basis of liquidation threshold
    
    
    */

    function _calculateHealthFactor(uint256 mintedDscCoin, uint256 collateralValueInUsd)
        internal
        pure
        returns (uint256)
    {
        if (mintedDscCoin < 0) {
            return type(uint256).max;
        }
        uint256 collateralAdjustedForThreshHold =
            (collateralValueInUsd * LIQUIDATION_THRESHHOLD) / LIQUIDATION_PRECISION; // get actual amount of collateral with threshold value

        return (collateralAdjustedForThreshHold * PRECISION) / mintedDscCoin; // here we are calcualatin health factor
    }

    function _checkUserHealthFactor(address user) private view returns (uint256) {
        // call function  which return mintedDSC and collateral value in usd
        (uint256 mintedDSC, uint256 collateralValueInusd) = _getAcountInfo(user);

        return _calculateHealthFactor(mintedDSC, collateralValueInusd);
    }

    function _getAcountInfo(address user) internal view returns (uint256 mintedDsc, uint256 collateralValueInUsd) {
        mintedDsc = s_DSCminted[user];
        // call function return totalCollateral value in usd
        collateralValueInUsd = getAccountCollateralValue(user);
        return (mintedDsc, collateralValueInUsd);
    }

    //////////////////////////////////////
    ///public and External view functions/////
    //////////////////////////////////////

    function calculateHealthFactor(uint256 mintedCoin, uint256 collateralValueInUsd) public pure returns (uint256) {
        return _calculateHealthFactor(mintedCoin, collateralValueInUsd);
    }

    function checkUserHealthFactor(address user) external view returns (uint256) {
        return _checkUserHealthFactor(user);
    }

    function getAccountCollateralValue(address _user) public view returns (uint256 totalCollateralValue) {
        // first loop through the collateral TokenAddress
        // then get the amount
        // then call the function which give the token value in usd

        for (uint256 i = 0; i < s_collateralTokens.length; i++) {
            uint256 tokenAmount = s_collateralDeposited[_user][s_collateralTokens[i]];
            totalCollateralValue += getColletralValueInUsd(tokenAmount, s_collateralTokens[i]);
        }
        return totalCollateralValue;
    }

    function getTokenfromUsd(address tokenAddress, uint256 amountOfUSdInWei) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeed[tokenAddress]);

        (, int256 price,,,) = priceFeed.latestRoundData();

        // $2000 is in 1eth
        // $500 eth? ==> 500/2000==> 0.25;

        return ((amountOfUSdInWei * PRECISION_FEED) / (uint256(price) * ADDITIONAL_PRECISION_FEED));
    }

    function getColletralValueInUsd(uint256 tokenAmount, address tokenAddress) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeed[tokenAddress]);
        (, int256 price,,,) = priceFeed.stalePriceCheck(); // return value price * 1e8
        // 1 ETH = 1000 USD
        // The returned value from Chainlink will be 1000 * 1e8
        // Most USD pairs have 8 decimals, so we will just pretend they all do
        // We want to have everything in terms of WEI, so we add 10 zeros at the end

        return ((uint256(price) * ADDITIONAL_PRECISION_FEED) * tokenAmount) / PRECISION_FEED;
    }

    function getAccountInfo(address user) public view returns (uint256 mintedDsc, uint256 collateralValueInUsd) {
        (mintedDsc, collateralValueInUsd) = _getAcountInfo(user);
        return (mintedDsc, collateralValueInUsd);
    }

    function getPrecision() public view returns (uint256) {
        return PRECISION;
    }

    function getAdditionalFeedPrecision() public view returns (uint256) {
        return ADDITIONAL_PRECISION_FEED;
    }

    function getLiquidationBonus() public view returns (uint256) {
        return LIQUIDATION_BONUS;
    }

    function getCollateralTokenPriceFeed(address token) external view returns (address) {
        return s_priceFeed[token];
    }

    function getCollateralTokens() public view returns (address[] memory) {
        return s_collateralTokens;
    }

    function getMinHealthFactor() public view returns (uint256) {
        return MIN_HEALTH_FACTOR;
    }

    function getLiquidationThreshold() public view returns (uint256) {
        return LIQUIDATION_THRESHHOLD;
    }

    function getCollateralBalanceOfUser(address user, address collateralAddress) public view returns (uint256) {
        return s_collateralDeposited[user][collateralAddress];
    }

    function getDsc() public view returns (address) {
        return address(i_dsc);
    }
}
