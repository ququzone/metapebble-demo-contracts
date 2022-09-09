// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

contract StreamToken is Ownable, ReentrancyGuard, ERC20 {
    // one day
    uint256 constant public CLAIM_PERIOD = 86400;

    bytes32 public constant EIP712DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );
    bytes32 public immutable DOMAIN_SEPARATOR;
    bytes32 internal constant CLAIM_TYPE_HASH = keccak256(
        "Claim(address user,uint256 date,uint256 value)"
    );

    address public validator;
    // pebble user => date => user claimed amount
    mapping(address => mapping(uint256 => uint256)) private _claimed;

    event ValidatorChanged(address indexed previousValidator, address indexed validator);
    event Claimed(address indexed user, uint256 indexed date, uint256 value);

    constructor(address validator_) ERC20("Metapebble Demo Stream Token", "MDST") {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                EIP712DOMAIN_TYPEHASH,
                keccak256(bytes("StreamToken")),
                keccak256(bytes('1')),
                block.chainid,
                address(this)
            )
        );

        validator = validator_;
        emit ValidatorChanged(address(0), validator);
    }

    function changeValidator(address validator_) external onlyOwner {
        address previous = validator;
        validator = validator_;
        emit ValidatorChanged(previous, validator);
    }

    function currentPeriod() public view returns (uint256) {
        return block.timestamp / CLAIM_PERIOD * CLAIM_PERIOD;
    }

    function claimedAmount(address user_, uint256 date_) public view returns (uint256) {
        return _claimed[user_][date_];
    }

    function claimedAmount(address user_) external view returns (uint256) {
        return claimedAmount(user_, currentPeriod());
    }

    function hashClaim(address user_, uint256 date_, uint256 value_) public pure returns (bytes32) {
        return keccak256(
            abi.encode(
                CLAIM_TYPE_HASH,
                user_,
                date_,
                value_
            )
        );
    }

    function _claim(address user_, uint256 value_, uint8 v_, bytes32 r_, bytes32 s_) internal {
        uint256 _date = currentPeriod();
        uint256 claimedAmount = _claimed[user_][_date];
        require(claimedAmount < value_, "already claimed");
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            hashClaim(user_, _date, value_)
        ));
        require(ecrecover(digest, v_, r_, s_) == validator, "invalid signature");

        _claimed[user_][_date] = value_;
        _mint(user_, value_ - claimedAmount);
        emit Claimed(user_, _date, value_ - claimedAmount);
    }

    function claim(address user_, uint256 value_, uint8 v_, bytes32 r_, bytes32 s_) external nonReentrant {
        _claim(user_, value_, v_, r_, s_);
    }

    function claim(uint256 value_, uint8 v_, bytes32 r_, bytes32 s_) external nonReentrant {
        _claim(msg.sender, value_, v_, r_, s_);
    }
}
