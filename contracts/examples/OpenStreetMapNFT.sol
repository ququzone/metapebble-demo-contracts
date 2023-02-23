// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract OpenStreetMapNFT is ERC1155, Ownable {
    constructor() ERC1155("https://metapebble-nft-demo.onrender.com/api/nft/") {
    }

    function setURI(string memory uri_) external onlyOwner {
        _setURI(uri_);
    }

    function mint(address account, uint256 id) external {
        _mint(account, id, 1, "");
    }

    function uri(uint256 _tokenId) public view virtual override returns (string memory) {
        string memory baseURI = super.uri(_tokenId);
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, Strings.toString(_tokenId)))
                : "";
    }
}
