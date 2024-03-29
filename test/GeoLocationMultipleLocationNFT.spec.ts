import { ethers } from "hardhat"
import { expect } from "chai"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"

import { GeoLocationDataVerifier } from "../typechain/contracts/GeoLocationDataVerifier"
import { GeoLocationMultipleLocationNFT } from "../typechain/contracts/examples/GeoLocationMultipleLocationNFT"

describe("GeoLocationMultipleLocationNFT", function () {
    let verifier: GeoLocationDataVerifier
    let token: GeoLocationMultipleLocationNFT
    let owner: SignerWithAddress
    let signer: SignerWithAddress
    let holder: SignerWithAddress

    const startTimestamp = Math.floor(new Date().valueOf() / 1000)

    before(async function () {
        ;[owner, signer, holder] = await ethers.getSigners()

        const feeManagerFactory = await ethers.getContractFactory("GeneralFeeManager")
        const feeManager = await feeManagerFactory.deploy(1000)
        const selectorFactory = await ethers.getContractFactory("VerifyFeeSelector")
        const selector = await selectorFactory.deploy(feeManager.address)

        const verifierFactory = await ethers.getContractFactory("GeoLocationDataVerifier")
        verifier = (await verifierFactory.connect(owner).deploy()) as GeoLocationDataVerifier
        await verifier.initialize([signer.address], selector.address)

        const facory = await ethers.getContractFactory("GeoLocationMultipleLocationNFT")
        token = (await facory.connect(owner).deploy(
            [30400000], // long
            [120520000], // lat
            [1000], // 1km
            [startTimestamp],
            [startTimestamp + 1000],
            verifier.address,
            "ShangHai GeoLocation NFT",
            "SHP"
        )) as GeoLocationMultipleLocationNFT
        await token.addPlaceManager(owner.address)
    })

    it("check basic info", async function () {
        expect("ShangHai GeoLocation NFT").to.equal(await token.name())
        expect("SHP").to.equal(await token.symbol())
    })

    it("check claim", async function () {
        const deviceHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("12345"))
        const hash = ethers.utils.solidityKeccak256(
            ["address", "int256", "int256", "uint256", "bytes32", "uint256", "uint256"],
            [
                holder.address,
                30400000,
                120520000,
                1000,
                deviceHash,
                startTimestamp,
                startTimestamp + 1000,
            ]
        )
        const messageHashBinary = ethers.utils.arrayify(hash)

        const signature = await signer.signMessage(messageHashBinary)

        await expect(
            token
                .connect(owner)
                ["claim(int256,int256,uint256,bytes32,uint256,uint256,bytes)"](
                    30400000,
                    120520000,
                    1000,
                    deviceHash,
                    startTimestamp,
                    startTimestamp + 1000,
                    signature,
                    { value: 1000 }
                )
        ).to.be.revertedWith("invalid signature")

        expect(0).to.equal(await token.balanceOf(holder.address))
        await token
            .connect(holder)
            ["claim(int256,int256,uint256,bytes32,uint256,uint256,bytes)"](
                30400000,
                120520000,
                1000,
                deviceHash,
                startTimestamp,
                startTimestamp + 1000,
                signature,
                { value: 1000 }
            )
        expect(1).to.equal(await token.balanceOf(holder.address))

        await expect(
            token
                .connect(holder)
                ["claim(int256,int256,uint256,bytes32,uint256,uint256,bytes)"](
                    30400000,
                    120520000,
                    1000,
                    deviceHash,
                    startTimestamp,
                    startTimestamp + 1000,
                    signature,
                    { value: 1000 }
                )
        ).to.be.revertedWith("already claimed")
    })

    it("check add place", async function () {
        await expect(
            token.addPlace(30400000, 120520000, 1000, startTimestamp, startTimestamp + 1000)
        ).to.be.revertedWith("repeated place")

        await expect(
            token.addPlace(304000000, 120520000, 1000, startTimestamp, startTimestamp + 1000)
        ).to.be.revertedWith("invalid lat")
        await expect(
            token.addPlace(30400000, 1205000000, 1000, startTimestamp, startTimestamp + 1000)
        ).to.be.revertedWith("invalid long")

        expect(1).to.equal(await token.palceCount())

        await token.addPlace(30400000, 121520000, 10000, startTimestamp, startTimestamp + 1000)
        expect(2).to.equal(await token.palceCount())

        const place1Hash = await token.placesHash(1)
        const place1 = await token.places(place1Hash)
        expect(121520000).to.equals(place1.long.toNumber())
        expect(30400000).to.equals(place1.lat.toNumber())
        expect(10000).to.equals(place1.maxDistance.toNumber())
    })
})
