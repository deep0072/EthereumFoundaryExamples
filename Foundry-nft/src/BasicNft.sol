// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/*
 * @title BasicNft
 * @author Deepak
 * @notice this contract is to mint nft
 * @dev Implements openzeppelin for nft minting
 */

contract BasicNft is ERC721 {
    uint256 private s_tokenCounter; // counter for nft  token id
    mapping(uint256 => string) private s_tokenIdtoUri;

    constructor() ERC721("mark52", "mrk") {
        s_tokenCounter = 0;
    }

    function mintNft(string memory _tokenUri) public {
        s_tokenIdtoUri[s_tokenCounter] = _tokenUri;
        _safeMint(msg.sender, s_tokenCounter); // here we are setting balance of nft to the minter.
        s_tokenCounter++;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        return s_tokenIdtoUri[_tokenId];
    }
}
