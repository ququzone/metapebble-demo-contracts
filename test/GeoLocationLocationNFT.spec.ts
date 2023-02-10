import { ethers } from "hardhat"
import { expect } from "chai"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"

import { GeoLocationDataVerifier } from "../typechain/contracts/GeoLocationDataVerifier"
import { GeoLocationFixedLocationNFT } from "../typechain/contracts/examples/GeoLocationFixedLocationNFT"

describe("GeoLocationFixedLocationNFT", function () {
    let verifier: GeoLocationDataVerifier
    let token: GeoLocationFixedLocationNFT
    let owner: SignerWithAddress
    let signer: SignerWithAddress
    let holder: SignerWithAddress

    before(async function () {
        ;[owner, signer, holder] = await ethers.getSigners()

        const feeManagerFactory = await ethers.getContractFactory("GeneralFeeManager")
        const feeManager = await feeManagerFactory.deploy(1000)
        const selectorFactory = await ethers.getContractFactory("VerifyFeeSelector")
        const selector = await selectorFactory.deploy(feeManager.address)

        const verifierFactory = await ethers.getContractFactory("GeoLocationDataVerifier")
        verifier = (await verifierFactory.connect(owner).deploy()) as GeoLocationDataVerifier
        await verifier.initialize([signer.address], selector.address)

        const facory = await ethers.getContractFactory("GeoLocationFixedLocationNFT")
        token = (await facory.connect(owner).deploy(
            120520000, // lat
            30400000, // long
            1000, // 1km
            verifier.address,
            "ShangHai GeoLocation NFT",
            "SHP"
        )) as GeoLocationFixedLocationNFT
    })

    it("check basic info", async function () {
        expect("ShangHai GeoLocation NFT").to.equal(await token.name())
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
                .claim(120520000, 30400000, 100, deviceHash, 1668131000, 1668133000, signature, {
                    value: 1000,
                })
        ).to.be.revertedWith("invalid signature")

        expect(0).to.equal(await token.balanceOf(holder.address))
        await token
            .connect(holder)
            .claim(120520000, 30400000, 100, deviceHash, 1668131000, 1668133000, signature, {
                value: 1000,
            })
        expect(1).to.equal(await token.balanceOf(holder.address))

        expect(1000).to.equal(await ethers.provider.getBalance(verifier.address))

        await verifier
            .connect(owner)
            .withdrawFee("0x8896780a7912829781f70344ab93e589dddb2930", 1000)
        expect(0).to.equal(await ethers.provider.getBalance(verifier.address))
        expect(1000).to.equal(
            await ethers.provider.getBalance("0x8896780a7912829781f70344ab93e589dddb2930")
        )

        await expect(
            token
                .connect(holder)
                .claim(120520000, 30400000, 100, deviceHash, 1668131000, 1668133000, signature, {
                    value: 1000,
                })
        ).to.be.revertedWith("already claimed")
    })
})
