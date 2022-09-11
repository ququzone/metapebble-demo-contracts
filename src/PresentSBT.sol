// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "./sbt/SBT.sol";

contract PresentSBT is ReentrancyGuard, Ownable, SBT {
    event ValidatorChanged(address indexed previousValidator, address indexed validator);
    event Claimed(address indexed user);

    bytes32 public constant EIP712DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );
    bytes32 public immutable DOMAIN_SEPARATOR;
    bytes32 internal constant CLAIM_TYPE_HASH = keccak256(
        "Claim(address user)"
    );

    address public validator;
    uint256 private _tokenId;
    string private _uri;

    constructor(address validator_) SBT("Metapebble Demo Present SBT", "MDPT") {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                EIP712DOMAIN_TYPEHASH,
                keccak256(bytes("PresentSBT")),
                keccak256(bytes('1')),
                block.chainid,
                address(this)
            )
        );

        validator = validator_;
        _uri = "";
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

    function _baseURI() internal override view virtual returns (string memory) {
        return _uri;
    }

    function setBaseURI(string calldata uri_) external onlyOwner {
        _uri = uri_;
    }

    function hashClaim(address user_) public pure returns (bytes32) {
        return keccak256(
            abi.encode(
                CLAIM_TYPE_HASH,
                user_
            )
        );
    }

    function _claim(address user_, uint8 v_, bytes32 r_, bytes32 s_) internal {
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            hashClaim(user_)
        ));
        require(ecrecover(digest, v_, r_, s_) == validator, "invalid signature");

        _attest(user_, _tokenId);
        _tokenId++;
    }

    function claim(address user_, uint8 v_, bytes32 r_, bytes32 s_) external nonReentrant {
        _claim(user_, v_, r_, s_);
    }

    function claim(uint8 v_, bytes32 r_, bytes32 s_) external nonReentrant {
        _claim(msg.sender, v_, r_, s_);
    }
}
