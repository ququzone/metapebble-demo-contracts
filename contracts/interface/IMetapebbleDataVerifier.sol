// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMetapebbleDataVerifier {
    function isValidator(address account) external view returns (bool);

    function verify(bytes32 digest, bytes memory signature) external view returns (bool);

    function generateLocationDistanceDigest(
        address holder,
        int256 lat,
        int256 long,
        uint256 distance,
        bytes32 deviceHash,
        uint256 deviceTimestamp
    ) external view returns (bytes32);

    function generateDeviceDigest(
        address holder,
        bytes32 deviceHash,
        uint256 deviceTimestamp
    ) external view returns (bytes32);
}
