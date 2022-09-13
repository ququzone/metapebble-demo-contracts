// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/PresentSBT.sol";

contract PresentSBTTest is Test {
    uint256 internal validatorPrivateKey;
    address internal validator;

    PresentSBT public token;

    function setUp() public {
        validatorPrivateKey = 0xA11CE;
        validator = vm.addr(validatorPrivateKey);

        token = new PresentSBT(validator);
    }

    function getDigest(PresentSBT token_, address user_) public view returns (bytes32) {
        return keccak256(abi.encodePacked(
            "\x19\x01",
            token_.DOMAIN_SEPARATOR(),
            token_.hashClaim(user_)
        ));
    }

    function test_claim() public {
        bytes32 digest = getDigest(token, address(1));

        // sign digest
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(validatorPrivateKey, digest);

        assertEq(token.balanceOf(address(1)), 0);
        token.claim(
            address(1),
            v,
            r,
            s
        );

        assertEq(token.balanceOf(address(1)), 1);
    }

    function test_claimTwice() public {
        bytes32 digest = getDigest(token, address(1));

        // sign digest
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(validatorPrivateKey, digest);

        assertEq(token.balanceOf(address(1)), 0);
        token.claim(
            address(1),
            v,
            r,
            s
        );

        assertEq(token.balanceOf(address(1)), 1);
        vm.expectRevert(bytes("already claimed"));
        token.claim(
            address(1),
            v,
            r,
            s
        );
    }

    function test_claimErrorAccount() public {
        bytes32 digest = getDigest(token, address(1));

        // sign digest
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(validatorPrivateKey, digest);

        assertEq(token.balanceOf(address(1)), 0);
        vm.expectRevert(bytes("invalid signature"));
        token.claim(
            v,
            r,
            s
        );

        assertEq(token.balanceOf(address(1)), 0);
    }

    function test_tokenURI() public {
        bytes32 digest = getDigest(token, address(1));

        // sign digest
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(validatorPrivateKey, digest);

        vm.expectRevert(bytes("ERC721: invalid token ID"));
        token.tokenURI(0);
        assertEq(token.balanceOf(address(1)), 0);
        token.claim(
            address(1),
            v,
            r,
            s
        );
        assertEq(token.balanceOf(address(1)), 1);
        assertEq(token.ownerOf(0), address(1));
        assertEq(token.tokenURI(0), "");

        token.setBaseURI("https://metapebble.io/sbt/");
        assertEq(token.tokenURI(0), "https://metapebble.io/sbt/0");
    }

    function test_transfer() public {
        bytes32 digest = getDigest(token, address(1));
        // sign digest
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(validatorPrivateKey, digest);
        token.claim(
            address(1),
            v,
            r,
            s
        );

        vm.expectRevert(bytes("ERC721: caller is not token owner nor approved"));
        token.transferFrom(msg.sender, address(2), 0);
        
        vm.prank(address(1));
        vm.expectRevert(bytes("SOULBOUND: Non-Transferable"));
        token.transferFrom(address(1), address(2), 0);

        vm.prank(address(1));
        vm.expectRevert(bytes("SOULBOUND: Non-Transferable"));
        token.safeTransferFrom(address(1), address(2), 0);
    }

    function test_approve() public {
        bytes32 digest = getDigest(token, address(1));
        // sign digest
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(validatorPrivateKey, digest);
        token.claim(
            address(1),
            v,
            r,
            s
        );

        vm.expectRevert(Soulbound.selector);
        token.approve(address(2), 0);
        
        vm.startPrank(address(1));
        vm.expectRevert(Soulbound.selector);
        token.approve(address(2), 0);

        vm.expectRevert(Soulbound.selector);
        token.setApprovalForAll(address(2), true);
    }
}
