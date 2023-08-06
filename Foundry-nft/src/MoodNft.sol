// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

/*
 * @title MoodNft
 * @author Deepak
 * @notice this contract is to mint nft
 * @dev Implements openzeppelin for nft minting
 */

contract MoodNft is ERC721 {
    error MoodNft_cantFlipMoodIfnotOwner();

    string public s_HappySvgImageUri;
    string public s_CrySvgImageUri;
    uint256 public s_tokenCounter;

    enum Mood {
        HAPPY,
        CRY
    }

    mapping(uint256 => Mood) private s_tokenIdToMood;

    constructor(string memory HappySvgImageUri, string memory CrySvgImageUri) ERC721("MOOD NFT", "MNFT") {
        s_tokenCounter = 0;
        s_HappySvgImageUri = HappySvgImageUri;
        s_CrySvgImageUri = CrySvgImageUri;
    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY;
        s_tokenCounter++;
    }

    function flipMood(uint256 tokenId) external {
        if (!_isApprovedOrOwner(msg.sender, tokenId)) {
            revert MoodNft_cantFlipMoodIfnotOwner();
        }
        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            s_tokenIdToMood[tokenId] = Mood.CRY;
        } else {
            s_tokenIdToMood[tokenId] = Mood.HAPPY;
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenUri(uint256 _tokenId) public view returns (string memory) {
        // first check which svg uri is selected
        // and then set the set imageuri to  selected svg uri
        string memory imageUri;
        if (s_tokenIdToMood[_tokenId] == Mood.HAPPY) {
            imageUri = s_HappySvgImageUri;
        } else {
            imageUri = s_CrySvgImageUri;
        }

        // first create json and then concatenate string inside json withHelp of encodePacked
        // then convert into base64 using openzeppelin contract base64
        // after that concatenate baseUri with base64 and
        // then  convert it into string agaain
        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            name(),
                            '", "description": "nft reflect owner mood",',
                            '"attributes" :[{"traitType":"moodiness", "value":"100"}],',
                            '"image": "',
                            imageUri,
                            '"}'
                        )
                    )
                )
            )
        );
    }
}
