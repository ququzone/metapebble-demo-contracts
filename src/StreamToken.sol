// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract StreamToken is Ownable, ERC20 {
    // one day
    uint256 constant public CLAIM_PERIOD = 86400;

    address public validator;

    constructor() ERC20("Metapebble Demo Stream Token", "MDST") {
    }

    function currentPeriod() external view returns (uint256) {
        return block.timestamp / CLAIM_PERIOD * CLAIM_PERIOD;
    }
}
