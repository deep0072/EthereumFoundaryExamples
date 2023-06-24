// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./priceConverter.sol";

error Not_Sufficient_Amount();
error UnAuthorised();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;

    address[] public funders;

    mapping(address => uint256) public amountToFunded;

    address public immutable owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert UnAuthorised();
        }
        _;
    }

    function getVersion() public view returns (uint256) {
        uint256 version = s_priceFeed.version();

        return version;
    }

    function fund() public payable {
        if (msg.value.conversionRate(s_priceFeed) < MINIMUM_USD) {
            revert Not_Sufficient_Amount();
        }

        funders.push(msg.sender);
        amountToFunded[msg.sender] += msg.value;
    }

    function withDraw() public onlyOwner {
        for (uint256 funderIndex; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            amountToFunded[funder] = 0;
        }

        funders = new address[](0);

        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");

        require(success, "txn failed");
    }

    receive() external payable {
        fund();
    }
}
