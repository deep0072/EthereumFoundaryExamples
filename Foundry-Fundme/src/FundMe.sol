// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./priceConverter.sol";

error Not_Sufficient_Amount();
error UnAuthorised();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;

    address[] public s_funders;

    mapping(address => uint256) public s_amountToFunded;

    address public immutable s_owner;
    AggregatorV3Interface private s_priceFeed;
    uint256 ethPriceUsd;

    constructor(address priceFeed) {
        s_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    modifier onlyOwner() {
        if (msg.sender != s_owner) {
            revert UnAuthorised();
        }
        _;
    }

    function getVersion() public view returns (uint256) {
        uint256 version = s_priceFeed.version();

        return version;
    }

    function fund() public payable {
        ethPriceUsd = msg.value.conversionRate(s_priceFeed);
        if (ethPriceUsd < MINIMUM_USD) {
            revert Not_Sufficient_Amount();
        }

        s_funders.push(msg.sender);
        s_amountToFunded[msg.sender] += msg.value;
    }

    function withDraw() public onlyOwner {
        for (
            uint256 funderIndex;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_amountToFunded[funder] = 0;
        }

        s_funders = new address[](0);

        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");

        require(success, "txn failed");
    }

    function getAddressAmountToFunded(address _funder)
        public
        view
        returns (uint256)
    {
        uint256 amount = s_amountToFunded[_funder];
        return amount;
    }

    function getFunderWithIndex(uint256 funderIndex)
        public
        view
        returns (address)
    {
        return s_funders[funderIndex];
    }

    function getEthPriceUsd() public view returns (uint256) {
        return ethPriceUsd;
    }

    receive() external payable {
        fund();
    }
}
