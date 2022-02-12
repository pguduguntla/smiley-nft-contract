// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import {Base64} from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string[] bgColors = ["purple", "gray", "orange", "blue", "red", "green"];
    string[] fillColors = ["blue", "red", "green", "yellow", "gray", "orange"];

    string[] strokeColors = [
        "cyan",
        "black",
        "magenta",
        "blue",
        "red",
        "green",
        "yellow"
    ];

    event NewEpicNFTMinted(address sender, uint256 tokenId);

    string firstSvg =
        "<svg xmlns='http://www.w3.org/2000/svg' class='h-6 w-6' fill='";
    string secondSvg =
        "' viewBox='0 0 24 24' stroke='currentColor'><rect width='100%' height='100%' fill='";
    string thirdSvg = "' /><path stroke-linecap='round' stroke='";
    string fourthSvg =
        "' stroke-linejoin='round' stroke-width='2' d='M14.828 14.828a4 4 0 01-5.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z' /></svg>";

    constructor() ERC721("SquareNFT", "SQUARE") {
        console.log("My NFT");
    }

    function pickRandomBg(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(
            string(abi.encodePacked("BG_COLORS", Strings.toString(tokenId)))
        );
        rand = rand % bgColors.length;
        return bgColors[rand];
    }

    function pickRandomFill(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("FILL_COLORS", Strings.toString(tokenId)))
        );
        rand = rand % fillColors.length;
        return fillColors[rand];
    }

    function pickRandomStroke(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("STROKE_COLORS", Strings.toString(tokenId)))
        );
        rand = rand % strokeColors.length;
        return strokeColors[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function makeAnEpicNFT() public {
        uint256 newItemId = _tokenIds.current();
        string memory bg = pickRandomBg(newItemId);
        string memory fill = pickRandomFill(newItemId);
        string memory stroke = pickRandomStroke(newItemId);
        console.log(bg, fill, stroke);

        string memory finalSvg = string(
            abi.encodePacked(
                firstSvg,
                fill,
                secondSvg,
                bg,
                thirdSvg,
                stroke,
                fourthSvg
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        bg,
                        ", ",
                        fill,
                        ", ",
                        stroke,
                        " smiley face",
                        '", "description": "Beautiful smiley faces.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        _safeMint(msg.sender, newItemId);

        console.log("\n--------------------");
        console.log(
            string(
                abi.encodePacked(
                    "https://nftpreview.0xdev.codes/?code=",
                    finalTokenUri
                )
            )
        );
        console.log("--------------------\n");

        _setTokenURI(newItemId, finalTokenUri);

        console.log(
            "An NFT w/ ID %s has been minted to %s",
            newItemId,
            msg.sender
        );

        _tokenIds.increment();
        emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}
