// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../interface/IMetapebbleDataVerifier.sol";

contract MetapebbleVerifiedEnumerableNFT is ERC721Enumerable {
    event Claimed(address indexed holder, bytes32 indexed deviceHash, uint256 indexed tokenId);

    IMetapebbleDataVerifier public verifier;

    constructor(
        address _verifier,
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        verifier = IMetapebbleDataVerifier(_verifier);
    }

    // deviceHash => claimed address
    mapping(bytes32 => address) internal _claimedDevices;

    function claimed(bytes32 deviceHash_) external view returns (bool) {
        return _claimedDevices[deviceHash_] != address(0);
    }

    function claimedUser(bytes32 deviceHash_) external view returns (address) {
        return _claimedDevices[deviceHash_];
    }

    function _mint(
        uint256 tokenId,
        address holder,
        bytes32 deviceHash
    ) private {
        _mint(holder, tokenId);
        _claimedDevices[deviceHash] = holder;
        emit Claimed(holder, deviceHash, tokenId);
    }

    function _claim(
        uint256 tokenId,
        address holder,
        int256 lat,
        int256 long,
        uint256 distance,
        bytes32 deviceHash,
        uint256 startTimestamp,
        uint256 endTimestamp,
        bytes memory signature,
        uint256 value
    ) internal virtual {
        bytes32 digest = verifier.generateLocationDistanceDigest(
            holder,
            lat,
            long,
            distance,
            deviceHash,
            startTimestamp,
            endTimestamp
        );
        require(verifier.verify{value: value}(digest, signature), "invalid signature");

        _mint(tokenId, holder, deviceHash);
    }

    function _claim(
        uint256 tokenId,
        address holder,
        bytes32 deviceHash,
        uint256 startTimestamp,
        uint256 endTimestamp,
        bytes memory signature,
        uint256 value
    ) internal virtual {
        bytes32 digest = verifier.generateDeviceDigest(
            holder,
            deviceHash,
            startTimestamp,
            endTimestamp
        );
        require(verifier.verify{value: value}(digest, signature), "invalid signature");

        _mint(tokenId, holder, deviceHash);
    }
}
