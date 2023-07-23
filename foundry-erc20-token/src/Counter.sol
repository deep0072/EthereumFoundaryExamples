// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


contract Erc20Token {
    mapping(address => uint) private s_balances;

    function name() public pure returns (string memory) {
        return "DeepCoin";
    }

    function totalSupply() public pure returns (uint256) {
        return 100 ether; //100000000000000000000
    }

    function decimals() public pure returns (uint256) {
        return 18;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return s_balances[_owner];
    }

    function transfer(address _to, uint256 _amount) public {
        uint256 prevoiusBalances = balanceOf(msg.sender) + balanceOf(_to);

        s_balances[msg.sender] -= _amount;
        s_balances[_to] += _amount;

        require(prevoiusBalances == balanceOf(msg.sender) + balanceOf(_to));
    }
}
