module.exports = async ({ ethers, getNamedAccounts, deployments }) => {
    const { deploy, get, log } = deployments
    const { deployer } = await getNamedAccounts()

    const verifier = await get("GeoLocationDataVerifier")

    const startTimestamp = Math.floor(new Date().valueOf() / 1000) + 1000
    const endTimestamp = startTimestamp + 864000

    log(`Deploying GeoLocationVerifiedDrop...`)
    let deployResult = await deploy("GeoLocationVerifiedDrop", {
        from: deployer,
        log: true,
        args: [
            120520000, // lat
            30400000, // long
            1000, // 1km
            startTimestamp,
            endTimestamp,
            verifier.address,
            "1000000000000000000",
        ],
        deterministicDeployment: false,
    })
    if (deployResult.newlyDeployed) {
        log(
            `contract GeoLocationVerifiedDrop deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`
        )
    }
}

module.exports.dependencies = [`verifier`]
module.exports.tags = [`all`, `example`, `drop`]
