// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "./interface/IMetapebbleDataVerifier.sol";

contract MetapebbleDataVerifier is Ownable, IMetapebbleDataVerifier {
    event ValidatorChanged(address indexed previousValidator, address indexed validator);

    address public override validator;

    constructor(address _validator) {
        validator = _validator;
        emit ValidatorChanged(address(0), validator);
    }

    function valid(bytes32 digest, uint8 v, bytes32 r, bytes32 s) external view override returns (bool) {
        return ecrecover(digest, v, r, s) == validator;
    }

    function changeValidator(address validator_) external onlyOwner {
        address previous = validator;
        validator = validator_;
        emit ValidatorChanged(previous, validator);
    }
}
