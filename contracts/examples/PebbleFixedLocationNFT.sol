// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./MetapebbleVerifiedEnumerableNFT.sol";

contract PebbleFixedLocationNFT is ReentrancyGuard, MetapebbleVerifiedEnumerableNFT {
    int256 private lat;
    int256 private long;
    uint256 private maxDistance;

    uint256 private tokenId;

    constructor(
        int256 _lat,
        int256 _long,
        uint256 _maxDistance,
        address _verifier,
        string memory _name,
        string memory _symbol
    ) MetapebbleVerifiedEnumerableNFT(_verifier, _name, _symbol) {
        lat = _lat;
        long = _long;
        maxDistance = _maxDistance;
    }

    function claim(
        int256 lat_,
        int256 long_,
        uint256 distance_,
        bytes32 deviceHash_,
        uint256 startTimestamp_,
        uint256 endTimestamp_,
        bytes memory signature
    ) external payable nonReentrant {
        // fixed location verify logic
        require(_claimedDevices[deviceHash_] == address(0), "already claimed");
        require(lat_ == lat && long_ == long && distance_ <= maxDistance, "invalid location");

        _claim(
            tokenId,
            msg.sender,
            lat_,
            long_,
            distance_,
            deviceHash_,
            startTimestamp_,
            endTimestamp_,
            signature,
            msg.value
        );
        tokenId++;
    }
}
