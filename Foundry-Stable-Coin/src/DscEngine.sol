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

/**
    * @title DSCEngine
    * @author  Deepak 

    * This token is designed to have the token maintain a 1 token == $1 pegged
    * This stable coin has properties:
    * Exogenous Collateral
    * our coin should be overcollateralised. means collateral value should not be lower than the  current dsc value.
    * Dollar pegged
    * Algorithmically stabled
    * similar to DAI if dai had no governance and no fee was only backed by wBtc ,wETH

    * @notice This is the core of our system and handle all logic for mining and redeeming DSC as well as deposition and withdrawal of collateral
*/

contract DscEngine {
    //////////////////
    /// errors /////
    /////////////////

    error DscEngine__amountShouldMoreThanZero(uint amount);
    error DscEngine__tokenAndPriceFeedArrayArenotSame();
    error DscEngine__tokenNotAllowed(address tokenAddress);

    //////////////////
    ///state variable/////
    /////////////////

    mapping(address token => address priceFeedAddress) public s_priceFeed; // token address to priceFeed (weth/usd pair chainlINk priceFeedAddress)
    
    DecentralisedStableCoin private immutable i_dsc;



    //////////////////
    ///modifiers/////
    /////////////////

    modifier moreThanZero(uint amount) {
        if (amount <= 0) {
            revert DscEngine__amountShouldMoreThanZero(amount);
        }
        _;
    }

    modifier isTokenAllowed(address tokenAddress) {
        if (s_priceFeed[tokenAddress] == address(0)){
            revert DscEngine__tokenNotAllowed(tokenAddress);
        }
    }

    //////////////////
    ///functions/////
    /////////////////

    constructor( address[] memory tokenAddress, address[] memory priceFeedAddresses, address dscAdress) {

        if (tokenAddress.length != priceFeedAddresses){
            revert DscEngine__tokenAndPriceFeedArrayArenotSame();
        }
        for (uint i =0; i < memory.length; i++) {
            s_priceFeed[tokenAddress[i]]= priceFeedAddresses[i];
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
    function depositCollateral(
        address tokenCollateralAddress,
        uint256 collateralAmount
    ) external moreThanZero(collateralAmount) isTokenAllowed(tokenCollateralAddress){}

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    function mintDsc() external {}

    function burnDsc() external {}

    function liquidate() external {}
}
