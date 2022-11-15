import { ethers } from "hardhat"
import { expect } from "chai"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"

import { MetapebbleDataVerifier } from "../typechain/contracts/MetapebbleDataVerifier"
import { PebbleMultipleLocationNFT } from "../typechain/contracts/examples/PebbleMultipleLocationNFT"

describe("PebbleMultipleLocationNFT", function () {
    let verifier: MetapebbleDataVerifier
    let token: PebbleMultipleLocationNFT
    let owner: SignerWithAddress
    let signer: SignerWithAddress
    let holder: SignerWithAddress

    before(async function () {
        ;[owner, signer, holder] = await ethers.getSigners()

        const verifierFactory = await ethers.getContractFactory("MetapebbleDataVerifier")
        verifier = (await verifierFactory.connect(owner).deploy()) as MetapebbleDataVerifier
        await verifier.initialize([signer.address])

        const facory = await ethers.getContractFactory("PebbleMultipleLocationNFT")
        token = (await facory.connect(owner).deploy(
            [120520000], // lat
            [30400000], // long
            [1000], // 1km
            verifier.address,
            "ShangHai Pebble NFT",
            "SHP"
        )) as PebbleMultipleLocationNFT
    })

    it("check basic info", async function () {
        expect("ShangHai Pebble NFT").to.equal(await token.name())
        expect("SHP").to.equal(await token.symbol())
    })

    it("check claim", async function () {
        const deviceHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("12345"))
        const hash = ethers.utils.solidityKeccak256(
            ["address", "uint256", "uint256", "uint256", "bytes32", "uint256"],
            [holder.address, 120520000, 30400000, 100, deviceHash, 1668131000]
        )
        const messageHashBinary = ethers.utils.arrayify(hash)

        const signature = await signer.signMessage(messageHashBinary)

        await expect(
            token.connect(owner).claim(120520000, 30400000, 100, deviceHash, 1668131000, signature)
        ).to.be.revertedWith("invalid signature")

        expect(0).to.equal(await token.balanceOf(holder.address))
        await token
            .connect(holder)
            .claim(120520000, 30400000, 100, deviceHash, 1668131000, signature)
        expect(1).to.equal(await token.balanceOf(holder.address))

        await expect(
            token.connect(holder).claim(120520000, 30400000, 100, deviceHash, 1668131000, signature)
        ).to.be.revertedWith("already claimed")
    })
})
