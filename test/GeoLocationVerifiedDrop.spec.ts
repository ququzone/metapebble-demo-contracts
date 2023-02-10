import { ethers } from "hardhat"
import { expect } from "chai"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"

import { GeoLocationDataVerifier } from "../typechain/contracts/GeoLocationDataVerifier"
import { GeoLocationVerifiedDrop } from "../typechain/contracts/examples/GeoLocationVerifiedDrop"

describe("GeoLocationVerifiedDrop", function () {
    let verifier: GeoLocationDataVerifier
    let token: GeoLocationVerifiedDrop
    let owner: SignerWithAddress
    let signer: SignerWithAddress
    let holder: SignerWithAddress

    const startTimestamp = Math.floor(new Date().valueOf() / 1000) + 1000
    const endTimestamp = startTimestamp + 1000

    before(async function () {
        ;[owner, signer, holder] = await ethers.getSigners()

        const feeManagerFactory = await ethers.getContractFactory("GeneralFeeManager")
        const feeManager = await feeManagerFactory.deploy(1000)
        const selectorFactory = await ethers.getContractFactory("VerifyFeeSelector")
        const selector = await selectorFactory.deploy(feeManager.address)

        const verifierFactory = await ethers.getContractFactory("GeoLocationDataVerifier")
        verifier = (await verifierFactory.connect(owner).deploy()) as GeoLocationDataVerifier
        await verifier.initialize([signer.address], selector.address)

        const facory = await ethers.getContractFactory("GeoLocationVerifiedDrop")
        token = (await facory.connect(owner).deploy(
            120520000, // lat
            30400000, // long
            1000, // 1km
            startTimestamp,
            endTimestamp,
            verifier.address,
            100
        )) as GeoLocationVerifiedDrop
    })

    it("check basic info", async function () {
        expect("100").to.equal(await token.AMOUNT_PER_DEVICE())
        expect(false).to.equal(await token.claimable())
    })

    it("check claim", async function () {
        const holderBalance = await ethers.provider.getBalance(holder.address)

        const deviceHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("12345"))
        const hash = ethers.utils.solidityKeccak256(
            ["address", "int256", "int256", "uint256", "bytes32", "uint256", "uint256"],
            [holder.address, 120520000, 30400000, 100, deviceHash, startTimestamp, endTimestamp]
        )
        const messageHashBinary = ethers.utils.arrayify(hash)

        const signature = await signer.signMessage(messageHashBinary)

        await expect(
            token.connect(owner)["claim(uint256,bytes32,bytes)"](100, deviceHash, signature, {
                value: 1000,
            })
        ).to.be.revertedWith("no fund")

        await expect(owner.sendTransaction({ to: token.address, value: 90 })).to.be.revertedWith(
            "invalid amount"
        )
        await owner.sendTransaction({ to: token.address, value: 1000 })

        await expect(
            token
                .connect(owner)
                ["claim(uint256,bytes32,bytes)"](
                    100,
                    ethers.utils.keccak256(ethers.utils.toUtf8Bytes("123456")),
                    signature,
                    {
                        value: 1000,
                    }
                )
        ).to.be.revertedWith("invalid signature")

        expect(holderBalance).to.equal(await ethers.provider.getBalance(holder.address))
        await token
            .connect(owner)
            ["claim(address,uint256,bytes32,bytes)"](holder.address, 100, deviceHash, signature, {
                value: 1000,
            })
        expect(holderBalance.add(100)).to.equal(await ethers.provider.getBalance(holder.address))

        expect(1000).to.equal(await ethers.provider.getBalance(verifier.address))

        await verifier
            .connect(owner)
            .withdrawFee("0x0000000000000000000000000000000000000000", 1000)
        expect(0).to.equal(await ethers.provider.getBalance(verifier.address))
        expect(1000).to.equal(
            await ethers.provider.getBalance("0x0000000000000000000000000000000000000000")
        )

        await expect(
            token.connect(holder)["claim(uint256,bytes32,bytes)"](100, deviceHash, signature, {
                value: 1000,
            })
        ).to.be.revertedWith("already claimed")
    })
})
