// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Ownable2StepUpgradeable} from "./utils/Ownable2StepUpgradeable.sol";
import {IMetapebbleDataVerifier} from "./interface/IMetapebbleDataVerifier.sol";

contract MetapebbleDataVerifier is Initializable, Ownable2StepUpgradeable, IMetapebbleDataVerifier {
    using ECDSA for bytes32;

    address internal constant SENTINEL_VALIDATOR = address(0x1);

    event ValidatorAdded(address indexed validator);
    event ValidatorRemoved(address indexed validator);

    mapping(address => address) validators;

    function initialize(address[] memory _validators) public initializer {
        __Ownable2Step_init();

        address currentValidator = SENTINEL_VALIDATOR;
        for (uint256 i = 0; i < _validators.length; i++) {
            address validator = _validators[i];
            require(
                validator != address(0) &&
                    validator != SENTINEL_VALIDATOR &&
                    validator != address(this) &&
                    currentValidator != validator,
                "invalid validator"
            );
            // No duplicate validators allowed.
            require(validators[validator] == address(0), "repeated validator");
            validators[currentValidator] = validator;
            currentValidator = validator;
        }
        validators[currentValidator] = SENTINEL_VALIDATOR;
    }

    function verify(bytes32 hash, bytes memory signature) public view override returns (bool) {
        address signer = hash.toEthSignedMessageHash().recover(signature);
        return isValidator(signer);
    }

    function generateLocationDistanceDigest(
        address holder,
        int256 lat,
        int256 long,
        uint256 distance,
        bytes32 deviceHash,
        uint256 deviceTimestamp
    ) external pure override returns (bytes32) {
        return
            keccak256(abi.encodePacked(holder, lat, long, distance, deviceHash, deviceTimestamp));
    }

    function generateDeviceDigest(
        address holder,
        bytes32 deviceHash,
        uint256 deviceTimestamp
    ) external pure override returns (bytes32) {
        return keccak256(abi.encodePacked(holder, deviceHash, deviceTimestamp));
    }

    function isValidator(address _account) public view returns (bool) {
        return _account != SENTINEL_VALIDATOR && validators[_account] != address(0);
    }

    function addValidator(address _validator) external onlyOwner {
        require(
            _validator != address(0) &&
                _validator != SENTINEL_VALIDATOR &&
                _validator != address(this),
            "invalid validator"
        );
        require(validators[_validator] == address(0), "validator exists");
        validators[_validator] = validators[SENTINEL_VALIDATOR];
        validators[SENTINEL_VALIDATOR] = _validator;
        emit ValidatorAdded(_validator);
    }

    function removeValidator(address _prevValidator, address _validator) external onlyOwner {
        require(_validator != address(0) && _validator != SENTINEL_VALIDATOR, "invalid validator");
        require(validators[_prevValidator] == _validator, "error previous validator");
        validators[_prevValidator] = validators[_validator];
        validators[_validator] = address(0);
        emit ValidatorRemoved(_validator);
    }
}
