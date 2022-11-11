// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./MetapebbleVerifiedNFT.sol";
import "./interface/IMetapebbleDataVerifier.sol";

abstract contract MetapebbleVerifiedSBT is MetapebbleVerifiedNFT {
    constructor(address _verifier, string memory _name, string memory _symbol) MetapebbleVerifiedNFT(_verifier, _name, _symbol) {
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
