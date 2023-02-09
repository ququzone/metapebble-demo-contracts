// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../interface/IMetapebbleDataVerifier.sol";
import "../interface/IVerifyFeeSelector.sol";
import "../interface/IVerifyFeeManager.sol";

contract MetapebbleVerifiedDrop is Ownable, ReentrancyGuard {
    event Claimed(address indexed holder, bytes32 indexed deviceHash, uint256 amount);

    uint256 public AMOUNT_PER_DEVICE;
    IMetapebbleDataVerifier public verifier;
    // deviceHash => claimed address
    mapping(bytes32 => address) internal _claimedDevices;

    int256 public lat;
    int256 public long;
    uint256 public maxDistance;
    uint256 public startTimestamp;
    uint256 public endTimestamp;

    constructor(
        int256 _lat,
        int256 _long,
        uint256 _maxDistance,
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        address _verifier,
        uint256 _amount
    ) {
        require(_amount > 0, "invalid amount");
        require(
            // _startTimestamp > block.timestamp && _endTimestamp > _startTimestamp,
            _endTimestamp > _startTimestamp,
            "invalid time range"
        );
        require(_maxDistance != 0, "invalid distance");
        lat = _lat;
        long = _long;
        maxDistance = _maxDistance;
        startTimestamp = _startTimestamp;
        endTimestamp = _endTimestamp;
        verifier = IMetapebbleDataVerifier(_verifier);
        AMOUNT_PER_DEVICE = _amount;
    }

    receive() external payable {
        require(msg.value % AMOUNT_PER_DEVICE == 0, "invalid amount");
    }

    function refund() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function claimable() external view returns (bool) {
        return address(this).balance >= AMOUNT_PER_DEVICE;
    }

    function claimed(bytes32 deviceHash_) external view returns (bool) {
        return _claimedDevices[deviceHash_] != address(0);
    }

    function _claim(
        address payable holder,
        uint256 distance,
        bytes32 deviceHash,
        bytes memory signature,
        uint256 value
    ) internal virtual nonReentrant {
        require(_claimedDevices[deviceHash] == address(0), "already claimed");
        require(address(this).balance - msg.value >= AMOUNT_PER_DEVICE, "no fund");
        require(distance <= maxDistance, "invalid location");
        require(msg.value >= claimFee(), "miss verifier fee");

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

        _claimedDevices[deviceHash] = holder;
        holder.transfer(AMOUNT_PER_DEVICE);
        emit Claimed(holder, deviceHash, AMOUNT_PER_DEVICE);
    }

    function claim(
        address payable holder,
        uint256 distance,
        bytes32 deviceHash,
        bytes memory signature
    ) external payable {
        _claim(holder, distance, deviceHash, signature, msg.value);
    }

    function claim(
        uint256 distance,
        bytes32 deviceHash,
        bytes memory signature
    ) external payable {
        _claim(payable(msg.sender), distance, deviceHash, signature, msg.value);
    }

    function claimFee() public view returns (uint256) {
        return
            IVerifyFeeManager(
                IVerifyFeeSelector(verifier.verifyFeeSelector()).fetchVerifyFeeManager(
                    address(this)
                )
            ).fee(address(this));
    }
}
