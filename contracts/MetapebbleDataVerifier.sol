// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Ownable2StepUpgradeable} from "./utils/Ownable2StepUpgradeable.sol";
import {IMetapebbleDataVerifier} from "./interface/IMetapebbleDataVerifier.sol";

contract MetapebbleDataVerifier is Initializable, Ownable2StepUpgradeable, IMetapebbleDataVerifier {
    using ECDSA for bytes32;

    event ValidatorChanged(address indexed previousValidator, address indexed validator);

    address public override validator;

    function initialize(address _validator) initializer public {
        __Ownable2Step_init();
        validator = _validator;
        emit ValidatorChanged(address(0), validator);
    }

    function verify(bytes32 hash, bytes memory signature) public view override returns (bool) {
        return hash.toEthSignedMessageHash().recover(signature) == validator;
    }

    function verifyLocationDistance(
        address holder,
        uint256 lat,
        uint256 long,
        uint256 distance,
        bytes32 deviceHash,
        uint256 deviceTimestamp,
        uint256 verifyTimestamp,
        bytes memory signature
    ) external view override returns (bool) {
        bytes32 hash = keccak256(abi.encodePacked(holder, lat, long, distance, deviceHash, deviceTimestamp, verifyTimestamp));
        return verify(hash, signature);
    }

    function verifyDevice(
        address holder,
        bytes32 deviceHash,
        uint256 deviceTimestamp,
        uint256 verifyTimestamp,
        bytes memory signature
    ) external view override returns (bool) {
        bytes32 hash = keccak256(abi.encodePacked(holder, deviceHash, deviceTimestamp, verifyTimestamp));
        return verify(hash, signature);
    }

    function changeValidator(address validator_) external onlyOwner {
        address previous = validator;
        validator = validator_;
        emit ValidatorChanged(previous, validator);
    }
}
