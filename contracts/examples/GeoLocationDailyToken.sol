// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./GeoLocationVerifiedToken.sol";

contract GeoLocationDailyToken is ReentrancyGuard, GeoLocationVerifiedToken {
    // one day
    uint256 public constant CLAIM_PERIOD = 86400;
    uint256 public constant TOKEN_PER_DAY = 1e18;

    // pebble user => date => user claimed amount
    mapping(address => mapping(uint256 => uint256)) private _claimed;

    constructor(
        address _verifier,
        string memory _name,
        string memory _symbol
    ) GeoLocationVerifiedToken(_verifier, _name, _symbol) {}

    function currentPeriod() public view returns (uint256) {
        return (block.timestamp / CLAIM_PERIOD) * CLAIM_PERIOD;
    }

    function claimedAmount(address user_, uint256 date_) public view returns (uint256) {
        return _claimed[user_][date_];
    }

    function claimedAmount(address user_) external view returns (uint256) {
        return claimedAmount(user_, currentPeriod());
    }

    function claim(
        bytes32 deviceHash_,
        uint256 startTimestamp_,
        uint256 endTimestamp_,
        bytes memory signature
    ) external payable nonReentrant {
        address holder = msg.sender;
        uint256 _date = currentPeriod();
        uint256 _claimedAmount = _claimed[holder][_date];

        // claim verify logic
        require(_claimedAmount < 0, "already claimed");

        _claimed[holder][_date] = TOKEN_PER_DAY;
        _claim(
            TOKEN_PER_DAY,
            msg.sender,
            deviceHash_,
            startTimestamp_,
            endTimestamp_,
            signature,
            msg.value
        );
    }
}
