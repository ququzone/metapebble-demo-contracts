// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMetapebbleDataVerifier {
    function validator() external view returns (address);

    function valid(bytes32 digest, uint8 v, bytes32 r, bytes32 s) external view returns (bool);
}
