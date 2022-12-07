import { ethers } from "hardhat"
import { expect } from "chai"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"

import { MetapebbleDataVerifier } from "../typechain/contracts/MetapebbleDataVerifier"
import { PebbleFixedLocationNFT } from "../typechain/contracts/examples/PebbleFixedLocationNFT"

describe("PebbleFixedLocationNFT", function () {
    let verifier: MetapebbleDataVerifier
    let token: PebbleFixedLocationNFT
    let owner: SignerWithAddress
    let signer: SignerWithAddress
    let holder: SignerWithAddress

    before(async function () {
        ;[owner, signer, holder] = await ethers.getSigners()

        const feeManagerFactory = await ethers.getContractFactory("GeneralFeeManager")
        const feeManager = await feeManagerFactory.deploy(1000);
        const selectorFactory = await ethers.getContractFactory("VerifyFeeSelector")
        const selector = await selectorFactory.deploy(feeManager.address)

        const verifierFactory = await ethers.getContractFactory("MetapebbleDataVerifier")
        verifier = (await verifierFactory.connect(owner).deploy()) as MetapebbleDataVerifier
        await verifier.initialize([signer.address], selector.address)

        const facory = await ethers.getContractFactory("PebbleFixedLocationNFT")
        token = (await facory.connect(owner).deploy(
            120520000, // lat
            30400000, // long
            1000, // 1km
            verifier.address,
            "ShangHai Pebble NFT",
            "SHP"
        )) as PebbleFixedLocationNFT
    })

    it("check basic info", async function () {
        expect("ShangHai Pebble NFT").to.equal(await token.name())
        expect("SHP").to.equal(await token.symbol())
    })

    it("check claim", async function () {
        const deviceHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("12345"))
        const hash = ethers.utils.solidityKeccak256(
            ["address", "int256", "int256", "uint256", "bytes32", "uint256", "uint256"],
            [holder.address, 120520000, 30400000, 100, deviceHash, 1668131000, 1668133000]
        )
        const messageHashBinary = ethers.utils.arrayify(hash)

        const signature = await signer.signMessage(messageHashBinary)

        await expect(
            token
                .connect(owner)
                .claim(120520000, 30400000, 100, deviceHash, 1668131000, 1668133000, signature, {value: 1000})
        ).to.be.revertedWith("invalid signature")

        expect(0).to.equal(await token.balanceOf(holder.address))
        await token
            .connect(holder)
            .claim(120520000, 30400000, 100, deviceHash, 1668131000, 1668133000, signature, {value: 1000})
        expect(1).to.equal(await token.balanceOf(holder.address))

        expect(1000).to.equal(await ethers.provider.getBalance(verifier.address))
                                                   
        await verifier.connect(owner).withdrawFee("0x0000000000000000000000000000000000000000", 1000)
        expect(0).to.equal(await ethers.provider.getBalance(verifier.address))
        expect(1000).to.equal(await ethers.provider.getBalance("0x0000000000000000000000000000000000000000"))

        await expect(
            token
                .connect(holder)
                .claim(120520000, 30400000, 100, deviceHash, 1668131000, 1668133000, signature, {value: 1000})
        ).to.be.revertedWith("already claimed")
    })
})
