module.exports = async ({ ethers, getNamedAccounts, deployments }) => {
    const { deploy, get, log } = deployments
    const { deployer } = await getNamedAccounts()

    const verifier = await get("MetapebbleDataVerifier")

    // log(`Deploying PebbleFixedLocationNFT...`)
    // let deployResult = await deploy("PebbleFixedLocationNFT", {
    //     from: deployer,
    //     log: true,
    //     args: [
    //         120520000, // lat
    //         30400000, // long
    //         1000, // 1km
    //         verifier.address,
    //         "ShangHai Pebble NFT",
    //         "SHP",
    //     ],
    //     deterministicDeployment: false,
    // })
    // if (deployResult.newlyDeployed) {
    //     log(
    //         `contract PebbleFixedLocationNFT deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`
    //     )
    // }

    // log(`Deploying PebbleOwnSBT...`)
    // deployResult = await deploy("PebbleOwnSBT", {
    //     from: deployer,
    //     log: true,
    //     args: [verifier.address, "Own Pebble SBT", "OPT"],
    //     deterministicDeployment: false,
    // })
    // if (deployResult.newlyDeployed) {
    //     log(
    //         `contract PebbleOwnSBT deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`
    //     )
    // }

    // log(`Deploying PebbleDailyToken...`)
    // deployResult = await deploy("PebbleDailyToken", {
    //     from: deployer,
    //     log: true,
    //     args: [verifier.address, "Pebble Daily Tiken", "PDT"],
    //     deterministicDeployment: false,
    // })
    // if (deployResult.newlyDeployed) {
    //     log(
    //         `contract PebbleDailyToken deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`
    //     )
    // }

    log(`Deploying PebbleMultipleLocationNFT...`)
    const startTimestamp = Math.floor(new Date().valueOf() / 1000)
    const deployResult = await deploy("PebbleMultipleLocationNFT", {
        from: deployer,
        log: true,
        args: [
            [30400000, 30270960], // lat
            [120520000, 120041443], // long
            [1000, 1000], // 1km
            [startTimestamp, startTimestamp],
            [startTimestamp + 1000, startTimestamp + 2592000],
            verifier.address,
            "Multiple Place Pebble NFT",
            "MPT",
        ],
        deterministicDeployment: false,
    })
    if (deployResult.newlyDeployed) {
        log(
            `contract PebbleMultipleLocationNFT deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`
        )
    }
}

module.exports.dependencies = [`verifier`]
module.exports.tags = [`all`, `example`]
