// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interface/IMetapebbleDataVerifier.sol";
import "../interface/IVerifyFeeSelector.sol";
import "../interface/IVerifyFeeManager.sol";

contract MetapebbleVerifiedToken is ERC20 {
    event Claimed(address indexed holder, bytes32 indexed deviceHash, uint256 amount);

    IMetapebbleDataVerifier public verifier;

    constructor(
        address _verifier,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        verifier = IMetapebbleDataVerifier(_verifier);
    }

    function _mint(
        uint256 amount,
        address holder,
        bytes32 deviceHash
    ) private {
        _mint(holder, amount);
        emit Claimed(holder, deviceHash, amount);
    }

    function _claim(
        uint256 amount,
        address holder,
        int256 lat,
        int256 long,
        uint256 distance,
        bytes32 deviceHash,
        uint256 startTimestamp,
        uint256 endTimestamp,
        bytes memory signature,
        uint256 value
    ) internal virtual {
        bytes32 digest = verifier.generateLocationDistanceDigest(
            holder,
            lat,
            long,
            distance,
            deviceHash,
            startTimestamp,
            endTimestamp
        );
        require(verifier.verify{value: value}(digest, signature), "invalid signature");

        _mint(amount, holder, deviceHash);
    }

    function _claim(
        uint256 amount,
        address holder,
        bytes32 deviceHash,
        uint256 startTimestamp,
        uint256 endTimestamp,
        bytes memory signature,
        uint256 value
    ) internal virtual {
        bytes32 digest = verifier.generateDeviceDigest(
            holder,
            deviceHash,
            startTimestamp,
            endTimestamp
        );
        require(verifier.verify{value: value}(digest, signature), "invalid signature");

        _mint(amount, holder, deviceHash);
    }

    function claimFee() external view returns (uint256) {
        return
            IVerifyFeeManager(
                IVerifyFeeSelector(verifier.verifyFeeSelector()).fetchVerifyFeeManager(
                    address(this)
                )
            ).fee(address(this));
    }
}
