import { ethers } from "hardhat"
import { expect } from "chai"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"

import { GeoLocationDataVerifier } from "../typechain/contracts/GeoLocationDataVerifier"
import { GeoLocationOwnSBT } from "../typechain/contracts/examples/GeoLocationOwnSBT"

describe("GeoLocationOwnSBT", function () {
    let verifier: GeoLocationDataVerifier
    let token: GeoLocationOwnSBT
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

        const facory = await ethers.getContractFactory("GeoLocationOwnSBT")
        token = (await facory
            .connect(owner)
            .deploy(verifier.address, "Own GeoLocation NFT", "OPT")) as GeoLocationOwnSBT
    })

    it("check basic info", async function () {
        expect("Own GeoLocation NFT").to.equal(await token.name())
        expect("OPT").to.equal(await token.symbol())
    })

    it("check claim", async function () {
        const deviceHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("12345"))
        const hash = ethers.utils.solidityKeccak256(
            ["address", "bytes32", "uint256", "uint256"],
            [holder.address, deviceHash, 1668131000, 1668133000]
        )
        const messageHashBinary = ethers.utils.arrayify(hash)

        const signature = await signer.signMessage(messageHashBinary)

        await expect(
            token
                .connect(owner)
                .claim(deviceHash, 1668131000, 1668133000, signature, { value: 1000 })
        ).to.be.revertedWith("invalid signature")

        expect(0).to.equal(await token.balanceOf(holder.address))
        await token
            .connect(holder)
            .claim(deviceHash, 1668131000, 1668133000, signature, { value: 1000 })
        expect(1).to.equal(await token.balanceOf(holder.address))

        await expect(
            token
                .connect(holder)
                .claim(deviceHash, 1668131000, 1668133000, signature, { value: 1000 })
        ).to.be.revertedWith("already claimed")

        await expect(
            token.connect(holder).transferFrom(holder.address, owner.address, 0)
        ).to.be.revertedWith("SOULBOUND: Non-Transferable")
    })
})
