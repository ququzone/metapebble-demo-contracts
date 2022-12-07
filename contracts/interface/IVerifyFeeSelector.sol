// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVerifyFeeSelector {
    function fetchVerifyFeeManager(address project) external view returns (address);
}
