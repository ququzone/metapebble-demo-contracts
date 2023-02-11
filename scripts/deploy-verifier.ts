import { ethers } from "hardhat"
import { GeoLocationDataVerifier } from "../typechain/contracts/GeoLocationDataVerifier"

async function main() {
    const owner = new ethers.Wallet(process.env.PRIVATE_KEY!, ethers.provider)

    const feeFactory = await ethers.getContractFactory("GeneralFeeManager")
    const fee = await feeFactory.deploy(0)
    await fee.deployed()
    console.log(`deployed GeneralFeeManager address: ${fee.address}`)

    const selectorFactory = await ethers.getContractFactory("VerifyFeeSelector")
    const selector = await selectorFactory.deploy(fee.address)
    await selector.deployed()
    console.log(`deployed VerifyFeeSelector address: ${selector.address}`)

    // testnet
    // const verifierAddr = "0xB9ae925fF8318915e3266e0EA41a37408033caC6"
    // mainnet
    const verifierAddr = "0x539057424d2A1A0B7D7Af6F322f34569b967b272"

    const verifierFactory = await ethers.getContractFactory("GeoLocationDataVerifier")
    const verifier = verifierFactory.attach(verifierAddr) as GeoLocationDataVerifier

    await verifier.connect(owner).changeVerifyFeeSelector(selector.address)
    console.log(`change VerifyFeeSelector to: ${selector.address}`)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
