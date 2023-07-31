// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/*
 * @title MoodNft
 * @author Deepak
 * @notice this contract is to mint nft
 * @dev Implements openzeppelin for nft minting
 */
contract MoodNft is ERC721 {
    string public s_sadSvg;
    string public s_crySvg;
    uint256 public s_tokenCounter;

    constructor(
        string memory sadSvg,
        string memory crySvg
    ) ERC721("MOOD NFT", "MNFT") {
        s_tokenCounter = 0;
        s_sadSvg = sadSvg;
        s_crySvg = crySvg;
    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter++;
    }
}
