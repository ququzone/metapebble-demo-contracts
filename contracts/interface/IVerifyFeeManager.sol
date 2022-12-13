// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVerifyFeeManager {
    function fee(address project) external view returns (uint256);

    function verify(address project, uint256 value) external returns (bool);
}
