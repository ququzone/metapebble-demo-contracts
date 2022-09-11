// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "./sbt/SBT.sol";

contract PresentSBT is Ownable, SBT {
    event ValidatorChanged(address indexed previousValidator, address indexed validator);
    event Claimed(address indexed user);

    address public validator;

    constructor(address validator_) SBT("Metapebble Demo Present SBT", "MDPT") {
        validator = validator_;
        emit ValidatorChanged(address(0), validator);
    }

    function attest(address) external override pure returns (uint256) {
        revert("Present SBT only claimable");
    }

    function burn() external override {
        uint256 tokenId = tokenIdOf(msg.sender);
        _burn(tokenId);
    }

    function revoke(address from) external override onlyOwner {
        _revoke(from);
    }
}
