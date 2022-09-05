metapebble demo contracts
=========================

## calculate signature

```
// cast keccak "Claim(address user,uint256 date,uint256 value)"
const claimTypeHash = "0xbc171cf1b63fcb59aae50a569d2b828037d7218ed98f1d84886955d12baaf4b8";

// cast abi-encode "some(bytes32,address,uint256,uint256)" 0xbc171cf1b63fcb59aae50a569d2b828037d7218ed98f1d84886955d12baaf4b8 0x0000000000000000000000000000000000000001 1662249600 10000
// cast keccak 0x... 
const claimHash = "0x7b35be5a90feae114094a55daf05b62958915f0e47254a7dca963c49a9f9cc1a";

// digest = keccak(0x + 1901 + DOMAIN_SEPARATOR + hashClaim) 
// digest = keccak(0x1901068b93a623a08ecc70daa7c30b273e48b9088aea1103bd6992af573a82c0ba197b35be5a90feae114094a55daf05b62958915f0e47254a7dca963c49a9f9cc1a)
const digest = "0x94ae32fd86658bde3e7a172aec0b200189c5dbb101e853528d292b4d00548671";

// sign digest
// use secp256k1 sign
```
