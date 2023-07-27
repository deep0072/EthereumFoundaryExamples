// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BasicNft is ERC721 {
    uint256 private s_tokenCounter; // counter for token id
    mapping(uint256 => string) private s_tokenIdtoUri;

    constructor() ERC721("mark52", "mrk") {
        s_tokenCounter = 0;
    }

    function mintNft(string memory _tokenUri) public {
        s_tokenIdtoUri[s_tokenCounter] = _tokenUri;
        _safeMint(msg.sender, s_tokenCounter); // here we are setting balance of nft to the minter.
        s_tokenCounter++;
    }

    function tokenURI(
        uint _tokenId
    ) public view override returns (string memory) {
        return s_tokenIdtoUri[_tokenId];
    }
}
