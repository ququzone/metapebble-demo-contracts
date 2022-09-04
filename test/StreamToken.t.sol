// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/StreamToken.sol";

contract CounterTest is Test {
    event ValidatorChanged(address indexed previousValidator, address indexed validator);

    StreamToken public token;
    function setUp() public {
       token = new StreamToken(address(0x31aC7b9Efef929d44F432d51C00bE13F206b85e8));
    }

    function testCurrentPeriod() public {
        vm.warp(1662249600);
        assertEq(token.currentPeriod(), 1662249600);

        vm.warp(1662297981);
        emit log_named_uint("current period", token.currentPeriod());
        assertEq(token.currentPeriod(), 1662249600);
    }

    function testChangeValidator() public {
        assertEq(token.validator(), address(0x31aC7b9Efef929d44F432d51C00bE13F206b85e8));
        vm.expectEmit(true, true, false, true);
        emit ValidatorChanged(address(0x31aC7b9Efef929d44F432d51C00bE13F206b85e8), address(0));
        token.changeValidator(address(0));
        assertEq(token.validator(), address(0));

        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        vm.prank(address(1));
        token.changeValidator(address(0));
    }
}
