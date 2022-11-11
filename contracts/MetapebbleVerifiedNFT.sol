// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./interface/IMetapebbleDataVerifier.sol";

abstract contract MetapebbleVerifiedNFT is Ownable, ERC721 {
    event Claimed(address indexed holder, bytes32 indexed deviceHash, uint256 indexed tokenId);

    IMetapebbleDataVerifier public verifier;

    constructor(address _verifier, string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        verifier = IMetapebbleDataVerifier(_verifier);
        _uri = "";
    }

    // deviceHash => claimed address
    mapping(bytes32 => address) internal _claimedDevices;
    uint256 internal _tokenId;
    string private _uri;

    function _baseURI() internal override view virtual returns (string memory) {
        return _uri;
    }

    function setBaseURI(string calldata uri_) external onlyOwner {
        _uri = uri_;
    }

    function claimed(bytes32 deviceHash_) external view returns (bool) {
        return _claimedDevices[deviceHash_] != address(0);
    }

    function claimedUser(bytes32 deviceHash_) external view returns (address) {
        return _claimedDevices[deviceHash_];
    }

    function _mint(address holder, bytes32 deviceHash) private {
        _mint(holder, _tokenId);
        _claimedDevices[deviceHash] = holder;
        emit Claimed(holder, deviceHash, _tokenId);
        _tokenId++;
    }

    function _claim(
        address holder,
        uint256 lat,
        uint256 long,
        uint256 distance,
        bytes32 deviceHash,
        uint256 deviceTimestamp,
        uint256 verifyTimestamp,
        bytes memory signature
    ) internal virtual {
        require(
            verifier.verifyLocationDistance(
                holder,
                lat,
                long,
                distance,
                deviceHash,
                deviceTimestamp,
                verifyTimestamp,
                signature
            ),
            "invalid signature"
        );

        _mint(holder, deviceHash);
    }

    function _claim(
        address holder,
        bytes32 deviceHash,
        uint256 deviceTimestamp,
        uint256 verifyTimestamp,
        bytes memory signature
    ) internal virtual {
        require(
            verifier.verifyDevice(
                holder,
                deviceHash,
                deviceTimestamp,
                verifyTimestamp,
                signature
            ),
            "invalid signature"
        );

        _mint(holder, deviceHash);
    }
}
