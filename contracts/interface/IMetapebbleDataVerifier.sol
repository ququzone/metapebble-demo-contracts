// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMetapebbleDataVerifier {
    function validator() external view returns (address);

    function verify(bytes32 digest, uint8 v, bytes32 r, bytes32 s) external view returns (bool);

    function verifyLocationDistance(
        address holder,
        uint256 lat,
        uint256 long,
        uint256 distance,
        bytes32 deviceHash,
        uint256 deviceTimestamp,
        uint256 verifyTimestamp,
        uint8 v, bytes32 r, bytes32 s
    ) external view returns (bool);
    
    function verifyDevice(
        address holder,
        bytes32 deviceHash,
        uint256 deviceTimestamp,
        uint256 verifyTimestamp,
        uint8 v, bytes32 r, bytes32 s
    ) external view returns (bool);
}
