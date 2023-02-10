module.exports = async ({ ethers, getNamedAccounts, deployments }) => {
    const { deploy, get, log } = deployments
    const { deployer } = await getNamedAccounts()

    const verifier = await get("GeoLocationDataVerifier")

    // log(`Deploying GeoLocationFixedLocationNFT...`)
    // let deployResult = await deploy("GeoLocationFixedLocationNFT", {
    //     from: deployer,
    //     log: true,
    //     args: [
    //         120520000, // lat
    //         30400000, // long
    //         1000, // 1km
    //         verifier.address,
    //         "ShangHai GeoLocation NFT",
    //         "SHP",
    //     ],
    //     deterministicDeployment: false,
    // })
    // if (deployResult.newlyDeployed) {
    //     log(
    //         `contract GeoLocationFixedLocationNFT deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`
    //     )
    // }

    // log(`Deploying GeoLocationOwnSBT...`)
    // deployResult = await deploy("GeoLocationOwnSBT", {
    //     from: deployer,
    //     log: true,
    //     args: [verifier.address, "Own GeoLocation SBT", "OPT"],
    //     deterministicDeployment: false,
    // })
    // if (deployResult.newlyDeployed) {
    //     log(
    //         `contract GeoLocationOwnSBT deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`
    //     )
    // }

    // log(`Deploying GeoLocationDailyToken...`)
    // deployResult = await deploy("GeoLocationDailyToken", {
    //     from: deployer,
    //     log: true,
    //     args: [verifier.address, "GeoLocation Daily Tiken", "PDT"],
    //     deterministicDeployment: false,
    // })
    // if (deployResult.newlyDeployed) {
    //     log(
    //         `contract GeoLocationDailyToken deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`
    //     )
    // }

    log(`Deploying GeoLocationMultipleLocationNFT...`)
    const startTimestamp = Math.floor(new Date().valueOf() / 1000)
    const deployResult = await deploy("GeoLocationMultipleLocationNFT", {
        from: deployer,
        log: true,
        args: [
            [36121174], // lat
            [-115169652], // long
            [5000], // 5km
            [startTimestamp], // start time
            [startTimestamp + 86400], // end time
            verifier.address,
            "CES-W3bstream NFT",
            "CWT",
        ],
        deterministicDeployment: false,
    })
    if (deployResult.newlyDeployed) {
        log(
            `contract GeoLocationMultipleLocationNFT deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`
        )
    }
}

module.exports.dependencies = [`verifier`]
module.exports.tags = [`all`, `example`]
