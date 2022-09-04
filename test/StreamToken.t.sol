// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/StreamToken.sol";

contract CounterTest is Test {
    StreamToken public token;
    function setUp() public {
       token = new StreamToken();
    }

    function testCurrentPeriod() public {
        vm.warp(1662249600);
        assertEq(token.currentPeriod(), 1662249600);

        vm.warp(1662297981);
        emit log_named_uint("current period", token.currentPeriod());
        assertEq(token.currentPeriod(), 1662249600);
    }
}
