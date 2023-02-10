// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Ownable2StepUpgradeable} from "./utils/Ownable2StepUpgradeable.sol";
import {IGeoLocationDataVerifier} from "./interface/IGeoLocationDataVerifier.sol";
import {IVerifyFeeSelector} from "./interface/IVerifyFeeSelector.sol";
import {IVerifyFeeManager} from "./interface/IVerifyFeeManager.sol";

contract GeoLocationDataVerifier is
    Initializable,
    Ownable2StepUpgradeable,
    IGeoLocationDataVerifier
{
    using ECDSA for bytes32;

    address internal constant SENTINEL_VALIDATOR = address(0x1);

    event ValidatorAdded(address indexed validator);
    event ValidatorRemoved(address indexed validator);

    mapping(address => address) validators;

    address public override verifyFeeSelector;

    function initialize(address[] memory _validators, address _verifyFeeSelector)
        public
        initializer
    {
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
        verifyFeeSelector = _verifyFeeSelector;
    }

    function verify(bytes32 hash, bytes memory signature) public payable override returns (bool) {
        address feeManager = IVerifyFeeSelector(verifyFeeSelector).fetchVerifyFeeManager(
            msg.sender
        );
        require(IVerifyFeeManager(feeManager).verify(msg.sender, msg.value), "invalid fee");
        address signer = hash.toEthSignedMessageHash().recover(signature);
        return isValidator(signer);
    }

    function generateLocationDistanceDigest(
        address holder,
        int256 lat,
        int256 long,
        uint256 distance,
        bytes32 deviceHash,
        uint256 startTimestamp,
        uint256 endTimestamp
    ) external pure override returns (bytes32) {
        require(endTimestamp >= startTimestamp, "invalid timestamp");
        return
            keccak256(
                abi.encodePacked(
                    holder,
                    lat,
                    long,
                    distance,
                    deviceHash,
                    startTimestamp,
                    endTimestamp
                )
            );
    }

    function generateDeviceDigest(
        address holder,
        bytes32 deviceHash,
        uint256 startTimestamp,
        uint256 endTimestamp
    ) external pure override returns (bytes32) {
        require(endTimestamp >= startTimestamp, "invalid timestamp");
        return keccak256(abi.encodePacked(holder, deviceHash, startTimestamp, endTimestamp));
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

    function changeVerifyFeeSelector(address _verifyFeeSelector) external onlyOwner {
        require(_verifyFeeSelector != address(0), "invalid selector");
        verifyFeeSelector = _verifyFeeSelector;
    }

    function withdrawFee(address payable to, uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "insufficient balance");
        to.transfer(amount);
    }
}
