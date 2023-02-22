// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract OpenStreetMapNFT is ERC1155, Ownable {
    string private _baseUri;
    mapping(uint256 => bool) private _tokenIds;

    constructor() ERC1155("") {
        _baseUri = "";
    }

    function setURI(string memory uri_) external onlyOwner {
        _setURI(uri_);
    }

    function addToken(uint256 _tokenId) external onlyOwner {
        if (!_tokenIds[_tokenId]) {
            _tokenIds[_tokenId] = true;
        }
    }

    function mint(address account, uint256 id) external {
        _requireExists(id);
        _mint(account, id, 1, "");
    }

    function uri(uint256 _tokenId) public view virtual override returns (string memory) {
        _requireExists(_tokenId);

        string memory baseURI = super.uri(_tokenId);
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, Strings.toString(_tokenId), ".json"))
                : "";
    }

    function _requireExists(uint256 tokenId) internal view virtual {
        require(_tokenIds[tokenId], "invalid token ID");
    }
}
