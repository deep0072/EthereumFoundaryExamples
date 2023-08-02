// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {MoodNft} from "../src/MoodNft.sol";
import {Test, console} from "forge-std/Test.sol";

contract MoodNftTest is Test {
    MoodNft moodNft;
    string constant s_HappySvgUri =
        "data:image/svg+xml;base64,PCFET0NUWVBFIGh0bWw+DQo8aHRtbD4NCjxoZWFkPg0KIA0KPC9oZWFkPg0KPGJvZHk+DQogICAgPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB3aWR0aD0iNTAwIiBoZWlnaHQ9IjUwMCI+DQogICAgPGNpcmNsZSBjeD0iMjUwIiBjeT0iMjUwIiByPSIyMDAiIGZpbGw9InllbGxvdyIgLz4NCiAgICA8Y2lyY2xlIGN4PSIxODAiIGN5PSIxODAiIHI9IjMwIiBmaWxsPSJibGFjayIgLz4NCiAgICA8Y2lyY2xlIGN4PSIzMjAiIGN5PSIxODAiIHI9IjMwIiBmaWxsPSJibGFjayIgLz4NCiAgICA8cGF0aCBkPSJNMjAwIDM1MCBRMjUwIDQwMCAzMDAgMzUwIiBzdHJva2U9ImJsYWNrIiBmaWxsPSJSIiAvPg0KDQogICAgPC9zdmc+DQo8L2JvZHk+DQo8L2h0bWw+DQo=";
    string constant s_CrySvgUri =
        "data:image/svg+xml;base64,PCFET0NUWVBFIGh0bWw+DQo8aHRtbD4NCjxoZWFkPg0KIA0KPC9oZWFkPg0KPGJvZHk+Im5vbmUiIC8+IC8+DQogIDxjaXJjbGUgY3g9IjMyMCIgY3k9IjI0MCIgcj0iMTAiIGZpbGw9ImJsdWUiIC8+Cjwvc3ZnPg0KDQo8L2JvZHk+DQo8L2h0bWw+";
    address immutable i_User = makeAddr("Deepak");

    function setUp() public {
        moodNft = new MoodNft(s_HappySvgUri, s_CrySvgUri);
    }

    function testViewTokenUri() external {
        vm.prank(i_User);
        moodNft.mintNft();
        console.log(moodNft.tokenUri(0));
    }
}
