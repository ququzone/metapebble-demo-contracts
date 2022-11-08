metapebble demo contracts
=========================

## Calculate signature

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


## Develop

```
forge build
forge test -vvv -w
// unworking need to investigate
forge script script/StreamToken.s.sol:Deploy \
    --rpc-url=$ETH_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast --legacy -vvvv

// deployed: 0xfe0DEED8041E7E69182Ff2ad49f1983f2554e3e8
forge create --rpc-url $ETH_RPC_URL \
    --constructor-args "0x8896780a7912829781f70344ab93e589dddb2930" \
    --private-key $PRIVATE_KEY --legacy \
    src/MetapebbleDataVerifier.sol:MetapebbleDataVerifier

// deployed: 0xD477bC2272e34fACf7F8E34cc442c28B7Ab7bd7F
forge create --rpc-url $ETH_RPC_URL \
    --constructor-args "0xfe0DEED8041E7E69182Ff2ad49f1983f2554e3e8" "Metapebble Demo Stream Token" "MDST" \
    --private-key $PRIVATE_KEY --legacy \
    src/StreamToken.sol:StreamToken

// deployed: 0xe2365135a35702877d533780Ab89aEd9b45991a6
forge create --rpc-url $ETH_RPC_URL \
    --constructor-args "0xfe0DEED8041E7E69182Ff2ad49f1983f2554e3e8" "Metapebble SBT" "MSBT" \
    --private-key $PRIVATE_KEY --legacy \
    src/PresentSBT.sol:PresentSBT

// deployed: 0x898EF2F18fB58039E58Ee748558baBFe7edF7845
forge create --rpc-url $ETH_RPC_URL \
    --constructor-args "0xfe0DEED8041E7E69182Ff2ad49f1983f2554e3e8" "Metapebble NFT" "MNFT" \
    --private-key $PRIVATE_KEY --legacy \
    src/PebbleNFT.sol:PebbleNFT
```