// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../interface/IMetapebbleDataVerifier.sol";

contract PebbleLocationNFT is ReentrancyGuard, Ownable, ERC721 {
    bytes32 public constant EIP712DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );
    bytes32 public immutable DOMAIN_SEPARATOR;
    bytes32 internal constant CLAIM_TYPEHASH = keccak256(
        "Claim(address user,bytes32 deviceHash)"
    );

    IMetapebbleDataVerifier public verifier;
    // deviceHash => claimed
    mapping(bytes32 => bool) private _claimedDevices;
    uint256 private _tokenId;
    string private _uri;

    constructor(address _verifier, string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                EIP712DOMAIN_TYPEHASH,
                keccak256(bytes("PebbleNFT")),
                keccak256(bytes('1')),
                block.chainid,
                address(this)
            )
        );

        verifier = IMetapebbleDataVerifier(_verifier);
        _uri = "";
    }

    function burn(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "no privilege");
        _burn(tokenId);
    }

    function _baseURI() internal override view virtual returns (string memory) {
        return _uri;
    }

    function setBaseURI(string calldata uri_) external onlyOwner {
        _uri = uri_;
    }

    function hashClaim(address user_, bytes32 deviceHash_) public pure returns (bytes32) {
        return keccak256(
            abi.encode(
                CLAIM_TYPEHASH,
                user_,
                deviceHash_
            )
        );
    }

    function claimed(bytes32 deviceHash_) external view returns (bool) {
        return _claimedDevices[deviceHash_];
    }

    function _claim(address user_, bytes32 deviceHash_, uint8 v_, bytes32 r_, bytes32 s_) internal {
        require(!_claimedDevices[deviceHash_], "already claimed");
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            hashClaim(user_, deviceHash_)
        ));
        require(verifier.valid(digest, v_, r_, s_), "invalid signature");

        _mint(user_, _tokenId);
        _claimedDevices[deviceHash_] = true;
        _tokenId++;
    }

    function claim(address user_, bytes32 deviceHash_, uint8 v_, bytes32 r_, bytes32 s_) external nonReentrant {
        _claim(user_, deviceHash_, v_, r_, s_);
    }

    function claim(bytes32 deviceHash_, uint8 v_, bytes32 r_, bytes32 s_) external nonReentrant {
        _claim(msg.sender, deviceHash_, v_, r_, s_);
    }
}
