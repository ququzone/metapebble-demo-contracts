import { ethers } from "hardhat"

async function main() {
    // testnet
    // const verifier = "0xB9ae925fF8318915e3266e0EA41a37408033caC6"
    // mainnet
    const verifier = "0x539057424d2A1A0B7D7Af6F322f34569b967b272"

    const startTimestamp = Math.floor(new Date().valueOf() / 1000) + 1000
    const endTimestamp = startTimestamp + 864000

    const factory = await ethers.getContractFactory("GeoLocationVerifiedDrop")
    const drop = await factory.deploy(
        30270000, // lat
        120040000, // long
        1000, // 1km
        startTimestamp,
        endTimestamp,
        verifier,
        "1000000000000000000"
    )
    await drop.deployed()

    console.log(`deployed GeoLocationVerifiedDrop address: ${drop.address}`)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
