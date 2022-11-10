// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SoulBoundToken is ERC721 {
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
    }

    function burn(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "No burn privilege");
        _burn(tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId, /* firstTokenId */
        uint256 batchSize
    ) internal virtual override {
        require(
            from == address(0) || to == address(0),
            "SOULBOUND: Non-Transferable"
        );
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
}
