// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./MetapebbleVerifiedEnumerableNFT.sol";

contract PebbleMultipleLocationNFT is Ownable, ReentrancyGuard, MetapebbleVerifiedEnumerableNFT {
    struct Place {
        uint256 lat;
        uint256 long;
        uint256 maxDistance;
    }

    bytes32[] public placesHash;
    mapping(bytes32 => Place) public places;

    uint256 private tokenId;

    constructor(
        uint256[] memory _lats,
        uint256[] memory _longs,
        uint256[] memory _maxDistances,
        address _verifier,
        string memory _name,
        string memory _symbol
    ) MetapebbleVerifiedEnumerableNFT(_verifier, _name, _symbol) {
        require(
            _lats.length == _longs.length && _lats.length == _maxDistances.length,
            "invalid place"
        );

        for (uint256 i = 0; i < _lats.length; i++) {
            require(_maxDistances[i] > 0, "invalid max distance");
            bytes32 hash = keccak256(abi.encodePacked(_lats[i], _longs[i]));
            require(places[hash].maxDistance == 0, "repeated place");

            places[hash] = Place({lat: _lats[i], long: _longs[i], maxDistance: _maxDistances[i]});
            placesHash.push(hash);
        }
    }

    function palceCount() external view returns (uint256) {
        return placesHash.length;
    }

    function addPlace(
        uint256 _lat,
        uint256 _long,
        uint256 _maxDistance
    ) external onlyOwner {
        require(_maxDistance > 0, "invalid max distance");
        bytes32 hash = keccak256(abi.encodePacked(_lat, _long));
        require(places[hash].maxDistance == 0, "repeated place");

        places[hash] = Place({lat: _lat, long: _long, maxDistance: _maxDistance});
        placesHash.push(hash);
    }

    function claim(
        uint256 lat_,
        uint256 long_,
        uint256 distance_,
        bytes32 deviceHash_,
        uint256 deviceTimestamp_,
        bytes memory signature
    ) external nonReentrant {
        // fixed location verify logic
        require(_claimedDevices[deviceHash_] == address(0), "already claimed");
        Place memory place = places[keccak256(abi.encodePacked(lat_, long_))];
        require(place.maxDistance > 0, "place not exists");
        require(distance_ <= place.maxDistance, "invalid location");

        _claim(
            tokenId,
            msg.sender,
            lat_,
            long_,
            distance_,
            deviceHash_,
            deviceTimestamp_,
            signature
        );
        tokenId++;
    }
}
