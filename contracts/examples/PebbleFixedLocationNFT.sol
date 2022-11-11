// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../MetapebbleVerifiedNFT.sol";

contract PebbleFixedLocationNFT is ReentrancyGuard, MetapebbleVerifiedNFT {
    uint256 private lat;
    uint256 private long;
    uint256 private maxDistance;

    constructor(
        uint256 _lat,
        uint256 _long,
        uint256 _maxDistance,
        address _verifier,
        string memory _name,
        string memory _symbol
    ) MetapebbleVerifiedNFT(_verifier, _name, _symbol) {
        lat = _lat;
        long = _long;
        maxDistance = _maxDistance;
    }

    function claim(
        uint256 lat_,
        uint256 long_,
        uint256 distance_,
        bytes32 deviceHash_,
        uint256 deviceTimestamp_,
        uint256 verifyTimestamp_,
        bytes memory signature
    ) external nonReentrant {
        // fixed location verify logic
        require(_claimedDevices[deviceHash_] == address(0), "already claimed");
        require(lat_ == lat && long_ == long && distance_ < maxDistance, "invalid location");

        _claim(
            msg.sender,
            lat_,
            long_,
            distance_,
            deviceHash_,
            deviceTimestamp_,
            verifyTimestamp_,
            signature
        );
    }
}
