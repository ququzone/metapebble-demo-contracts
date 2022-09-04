// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract StreamToken is Ownable, ERC20 {
    // one day
    uint256 constant public CLAIM_PERIOD = 86400;

    address public validator;
    // pebble user => date => user claimed
    mapping(address => mapping(uint256 => bool)) private _claimed;

    event ValidatorChanged(address indexed previousValidator, address indexed validator);
    event Claimed(address indexed user, address indexed date, uint256 value);

    constructor(address validator_) ERC20("Metapebble Demo Stream Token", "MDST") {
        validator = validator_;
        emit ValidatorChanged(address(0), validator);
    }

    function changeValidator(address validator_) external onlyOwner {
        address previous = validator;
        validator = validator_;
        emit ValidatorChanged(previous, validator);
    }

    function currentPeriod() external view returns (uint256) {
        return block.timestamp / CLAIM_PERIOD * CLAIM_PERIOD;
    }
}
