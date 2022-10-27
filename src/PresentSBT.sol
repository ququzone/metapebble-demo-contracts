// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "./interface/IMetapebbleDataVerifier.sol";
import "./sbt/SBT.sol";

contract PresentSBT is ReentrancyGuard, Ownable, SBT {
    event Attest(address indexed to, uint256 indexed tokenId);
    event Revoke(address indexed from, uint256 indexed tokenId);
    event Claimed(address indexed user);

    bytes32 public constant EIP712DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );
    bytes32 public immutable DOMAIN_SEPARATOR;
    bytes32 internal constant CLAIM_TYPEHASH = keccak256(
        "Claim(address user)"
    );

    IMetapebbleDataVerifier public verifier;
    uint256 private _tokenId;
    string private _uri;

    constructor(address _verifier, string memory _name, string memory _symbol) SBT(_name, _symbol) {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                EIP712DOMAIN_TYPEHASH,
                keccak256(bytes("PresentSBT")),
                keccak256(bytes('1')),
                block.chainid,
                address(this)
            )
        );

        verifier = IMetapebbleDataVerifier(_verifier);
        _uri = "";
    }

    function burn() external {
        if (ERC721.balanceOf(msg.sender) > 0) {
            uint256 tokenId = ERC721Enumerable.tokenOfOwnerByIndex(msg.sender, 0);
            _burn(tokenId);
        } else {
            revert DoesNotOwn();
        }
    }

    function revoke(address from) external onlyOwner {
        if (ERC721.balanceOf(msg.sender) > 0) {
            uint256 tokenId = ERC721Enumerable.tokenOfOwnerByIndex(from, 0);
            _burn(tokenId);
            emit Revoke(from, tokenId);
        } else {
            revert DoesNotOwn();
        }
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
                CLAIM_TYPEHASH,
                user_
            )
        );
    }

    function _claim(address user_, uint8 v_, bytes32 r_, bytes32 s_) internal {
        require(ERC721.balanceOf(user_) == 0, "already claimed");
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            hashClaim(user_)
        ));
        require(verifier.valid(digest, v_, r_, s_), "invalid signature");

        _mint(user_, _tokenId);
        emit Attest(user_, _tokenId);
        _tokenId++;
    }

    function claim(address user_, uint8 v_, bytes32 r_, bytes32 s_) external nonReentrant {
        _claim(user_, v_, r_, s_);
    }

    function claim(uint8 v_, bytes32 r_, bytes32 s_) external nonReentrant {
        _claim(msg.sender, v_, r_, s_);
    }
}
