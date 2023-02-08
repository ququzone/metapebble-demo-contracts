// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IVerifyFeeManager} from "./interface/IVerifyFeeManager.sol";

contract GeneralFeeManager is IVerifyFeeManager, Ownable {
    event FeeChanged(uint256 originFee, uint256 newFee);

    uint256 private baseFee;

    constructor(uint256 _fee) {
        baseFee = _fee;
        emit FeeChanged(0, _fee);
    }

    function changefee(uint256 _fee) external onlyOwner {
        emit FeeChanged(baseFee, _fee);
        baseFee = _fee;
    }

    function fee(address) external view override returns (uint256) {
        return baseFee;
    }

    function verify(address, uint256 value) external view override returns (bool) {
        return value >= baseFee;
    }
}
