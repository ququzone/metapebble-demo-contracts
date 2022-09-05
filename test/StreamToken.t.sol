// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/StreamToken.sol";

contract StreamTokenTest is Test {
    event ValidatorChanged(address indexed previousValidator, address indexed validator);

    uint256 internal validatorPrivateKey;
    address internal validator;

    StreamToken public token;

    function getDigest(StreamToken token_, address user_, uint256 date_, uint256 value_) public view returns (bytes32) {
        return keccak256(abi.encodePacked(
            "\x19\x01",
            token_.DOMAIN_SEPARATOR(),
            token_.hashClaim(user_, date_, value_)
        ));
    }

    function setUp() public {
        validatorPrivateKey = 0xA11CE;
        validator = vm.addr(validatorPrivateKey);

        token = new StreamToken(validator);
    }

    function testCurrentPeriod() public {
        vm.warp(1662249600);
        assertEq(token.currentPeriod(), 1662249600);

        vm.warp(1662297981);
        emit log_named_uint("current period", token.currentPeriod());
        assertEq(token.currentPeriod(), 1662249600);
    }

    function testChangeValidator() public {
        assertEq(token.validator(), validator);
        vm.expectEmit(true, true, false, true);
        emit ValidatorChanged(validator, address(0));
        token.changeValidator(address(0));
        assertEq(token.validator(), address(0));

        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        vm.prank(address(1));
        token.changeValidator(address(0));
    }

    function testClaim() public {
        bytes32 digest = getDigest(token, address(1), 1662249600, 10000);

        // sign digest
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(validatorPrivateKey, digest);

        vm.warp(1662297981);
        assertEq(token.balanceOf(address(1)), 0);
        token.claim(
            address(1),
            1662249600,
            10000,
            v,
            r,
            s
        );

        assertEq(token.balanceOf(address(1)), 10000);
    }
}
