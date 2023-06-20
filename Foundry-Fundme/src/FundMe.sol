// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "./priceConverter.sol";
error Not_Sufficient_Amount();
error UnAuthorised();

contract FundMe {
    using PriceConverter for uint256;
    uint256 minimumAmount = 5e18;

    address[] public funders;

    mapping(address => uint) public amountToFunded;

    address owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert UnAuthorised();
        }
        _;
    }

    function fund() public payable {
        if (msg.value.conversionRate() < minimumAmount) {
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
