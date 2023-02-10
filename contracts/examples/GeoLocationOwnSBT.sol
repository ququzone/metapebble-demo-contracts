// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./GeoLocationVerifiedSBT.sol";

contract GeoLocationOwnSBT is ReentrancyGuard, GeoLocationVerifiedSBT {
    uint256 private tokenId;

    constructor(
        address _verifier,
        string memory _name,
        string memory _symbol
    ) GeoLocationVerifiedSBT(_verifier, _name, _symbol) {}

    function claim(
        bytes32 deviceHash_,
        uint256 startTimestamp_,
        uint256 endTimestamp_,
        bytes memory signature
    ) external payable nonReentrant {
        // own GeoLocation verify logic
        require(_claimedDevices[deviceHash_] == address(0), "already claimed");

        _claim(
            tokenId,
            msg.sender,
            deviceHash_,
            startTimestamp_,
            endTimestamp_,
            signature,
            msg.value
        );
        tokenId++;
    }
}
