// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SimpleStorage {
    uint256 public myFavoriteNumber;

    struct People {
        string name;
        uint256 favNumber;
    }

    mapping(string => uint256) public nametoNumber;

    People[] public listOfPeople;

    function setFavNUmber(uint256 _myFavoriteNumber) public {
        myFavoriteNumber = _myFavoriteNumber;
    }

    function addPeople(string memory _name, uint256 _favNumber) public {
        listOfPeople.push(People(_name, _favNumber));

        nametoNumber[_name] = _favNumber;
    }

    function retreiveNumber() public view returns (uint256) {
        return myFavoriteNumber;
    }
}
