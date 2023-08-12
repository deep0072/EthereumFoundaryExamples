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

import {DecentralisedStableCoin} from "./DecentralisedStableCoin.sol";

import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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

    error DscEngine__amountShouldMoreThanZero(uint256 amount);
    error DscEngine__tokenAndPriceFeedArrayArenotSame();
    error DscEngine__tokenNotAllowed(address tokenAddress);
    error DscEngine__transferFailed();
    error DscEngine__userHeathFactorIsBroken(uint256 healthFactor);
    error DscEngine__mintingFailed();


    //////////////////
    ///state variable/////
    /////////////////

    mapping(address token => address priceFeedAddress) public s_priceFeed; // token address to priceFeed (weth/usd pair chainlINk priceFeedAddress)

    DecentralisedStableCoin private immutable i_dsc;
    uint256 private ADDITIONAL_PRECISION_FEED = 1e10;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;
    address[] private s_collateralTokens;
    mapping(address user => uint dscMinted) private s_DSCminted;
    uint256 private constant LIQUIDATION_THRESHHOLD = 50; 
    uint256 private constant LIQUIDATION_PRECISION = 100; 
    uint256 private constant PRECISION = 1e18; 
    uint256 private constant MIN_HEALTH_FACTOR = 1;
    
    


    //////////////////
    ///events/////
    /////////////////

    event CollateralDeposited(address indexed user, address indexed tokenAddress, uint amount);
    
  

    //////////////////
    ///modifiers/////
    /////////////////

    modifier moreThanZero(uint256 amount) {
        if (amount <= 0) {
            revert DscEngine__amountShouldMoreThanZero(amount);   
        }
        _;
    }

    modifier isTokenAllowed(address tokenAddress) {
        if (s_priceFeed[tokenAddress] == address(0)) {
            revert DscEngine__tokenNotAllowed(tokenAddress);
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
    function depositCollateralAndMintDsc() external {}

    /*
     * @params tokenCollateralAddress is the address of token to deposit as collateral
     * @params collateralAmount is the amount to deposit collateral
       
    
    */
    function depositCollateral(address tokenCollateralAddress, uint256 collateralAmount)
        external
        moreThanZero(collateralAmount)
        isTokenAllowed(tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += collateralAmount;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, collateralAmount);

        // now trasnfer collateral to this contract
        bool success  = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), collateralAmount);

        if (!success){
            revert DscEngine__transferFailed();
        }
    }

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    /*
    * @param amountDscToMint==> amoun of decentralised stablecoin to min
    * @notice must have collateral value more thant the threshold 
    
     */
    function mintDsc(uint256 amountDscToMint) moreThanZero(amountDscToMint) nonReentrant external {


        s_DSCminted[msg.sender]+=amountDscToMint;

        // check the minted Amount is more than the collateral amount or not
        _revertHealtFactorIsBroken(msg.sender);

        bool minted = i_dsc.mint(msg.sender, amountDscToMint);
        if(!minted){
            revert DscEngine__mintingFailed();
        }


    }

    function burnDsc() external {}

    function liquidate() external {}
    function getHealtFactor() external view  {}
    ////////////////////////////////////////////
    ///Internal and Private view functions//////
    ////////////////////////////////////////////

    function _revertHealtFactorIsBroken(address user) internal view {
        uint256 userHealthFactor  = _checkHealthFactor(user);
        if (userHealthFactor < MIN_HEALTH_FACTOR){
            revert DscEngine__userHeathFactorIsBroken(userHealthFactor);

        }

        // check healthFactor (if they have enough collateral)

    }

    /* 
       * this contract will calcualte the collatralised amount 
       * on the basis of liquidation threshold
    
    
    */
    function _checkHealthFactor(address user) private view returns(uint256){
        // call function  which return mintedDSC and collateral value in usd
        (uint256 mintedDSC, uint256 collateralValueInusd) = _getAcountInfo(user);
        uint256  collateralAdjustedForThreshHold = (collateralValueInusd *LIQUIDATION_THRESHHOLD)/LIQUIDATION_PRECISION; // get actual amount of collateral with threshold value

        return (collateralAdjustedForThreshHold * PRECISION)/mintedDSC; // here we are calcualatin health factor

    }

    function _getAcountInfo(address user) internal view returns(uint256 mintedDsc, uint256 collateralValueInUsd ){
        mintedDsc = s_DSCminted[user];
        // call function return totalCollateral value in usd 
        collateralValueInUsd = getAccountCollateralValue(user);
        return (mintedDsc, collateralValueInUsd);
         

    }



    //////////////////////////////////////
    ///public and External view functions/////
    //////////////////////////////////////

    function getAccountCollateralValue(address _user) public view returns(uint256 totalCollateralValue){
        // first loop through the collateral TokenAddress
        // then get the amount 
        // then call the function which give the token value in usd

        for(uint256 i = 0; i < s_collateralTokens.length; i++){
            uint256 tokenAmount = s_collateralDeposited[_user][s_collateralTokens[i]];
            totalCollateralValue+=getColletralValueInUsd(tokenAmount, s_collateralTokens[i]);
        }
        return totalCollateralValue;
    }
    function getColletralValueInUsd(uint256 tokenAmount,address tokenAddress) public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeed[tokenAddress]);
        (,int256 price,,,) = priceFeed.latestRoundData(); // return value price * 1e8
        return (uint256(price)*ADDITIONAL_PRECISION_FEED * tokenAmount)/1e18;


    }

    

}
