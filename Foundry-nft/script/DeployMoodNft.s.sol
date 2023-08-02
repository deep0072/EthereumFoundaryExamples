// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {MoodNft} from "../src/MoodNft.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNftDeployScript is Script {
    MoodNft moodNft;

    string constant s_HappySvgUri =
        "data:image/svg+xml;base64,PCFET0NUWVBFIGh0bWw+DQo8aHRtbD4NCjxoZWFkPg0KIA0KPC9oZWFkPg0KPGJvZHk+DQogICAgPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB3aWR0aD0iNTAwIiBoZWlnaHQ9IjUwMCI+DQogICAgPGNpcmNsZSBjeD0iMjUwIiBjeT0iMjUwIiByPSIyMDAiIGZpbGw9InllbGxvdyIgLz4NCiAgICA8Y2lyY2xlIGN4PSIxODAiIGN5PSIxODAiIHI9IjMwIiBmaWxsPSJibGFjayIgLz4NCiAgICA8Y2lyY2xlIGN4PSIzMjAiIGN5PSIxODAiIHI9IjMwIiBmaWxsPSJibGFjayIgLz4NCiAgICA8cGF0aCBkPSJNMjAwIDM1MCBRMjUwIDQwMCAzMDAgMzUwIiBzdHJva2U9ImJsYWNrIiBmaWxsPSJSIiAvPg0KDQogICAgPC9zdmc+DQo8L2JvZHk+DQo8L2h0bWw+DQo";
    string constant s_CrySvgUri =
        "data:image/svg+xml;base64,PCFET0NUWVBFIGh0bWw+DQo8aHRtbD4NCjxoZWFkPg0KIA0KPC9oZWFkPg0KPGJvZHk+DQo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjUwMCIgaGVpZ2h0PSI1MDAiPg0KICA8Y2lyY2xlIGN4PSIyNTAiIGN5PSIyNTAiIHI9IjIwMCIgZmlsbD0ieWVsbG93IiAvPg0KICA8Y2lyY2xlIGN4PSIxODAiIGN5PSIxODAiIHI9IjMwIiBmaWxsPSIjMDBmY2ZjIiAvPg0KICA8Y2lyY2xlIGN4PSIzMjAiIGN5PSIxODAiIHI9IjMwIiBmaWxsPSIjMGUwZTBlIiAvPg0KICA8cGF0aCBkPSJNMjAwIDM1MCBRMjUwIDMwMCAzMDAgMzUwIiBzdHJva2U9IiMwMDAwMDAiIGZpbGw9Im5vbmUiIC8+DQogIDxjaXJjbGUgY3g9IjE4MCIgY3k9IjI0MCIgcj0iMTAiIGZpbGw9ImJsdWUiIC8+DQogIDxjaXJjbGUgY3g9IjMyMCIgY3k9IjI0MCIgcj0iMTAiIGZpbGw9ImJsdWUiIC8+DQoNCjwvc3ZnPg0KDQo8L2JvZHk+DQo8L2h0bWw+";

    function run() external returns (MoodNft) {
        moodNft = new MoodNft(s_HappySvgUri, s_CrySvgUri);

        return moodNft;
    }

    /*
     * svgToImageUri==> convert svg to base64 format
     * first get svg as string convert it into bytes using encodePacked
     *then convert it into base64 format
     * then get baseuri and concatenate with base64 format with help of encodePacked
     * then convert the concatenated into string
     */
    function svgToImageUri(
        string memory _svg
    ) public pure returns (string memory) {
        string memory baseUrl = "data:image/svg+xml;base64,";
        string memory base64EncodedUri = Base64.encode(abi.encodePacked(_svg));

        return string(abi.encodePacked(baseUrl, base64EncodedUri));
    }
}
