module.exports = async ({ ethers, getNamedAccounts, deployments }) => {
    const { deploy, get, log } = deployments
    const { deployer } = await getNamedAccounts()

    const verifier = await get("MetapebbleDataVerifier")

    const startTimestamp = Math.floor(new Date().valueOf() / 1000) + 1000
    const endTimestamp = startTimestamp + 864000

    log(`Deploying MetapebbleVerifiedDrop...`)
    let deployResult = await deploy("MetapebbleVerifiedDrop", {
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
            `contract MetapebbleVerifiedDrop deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`
        )
    }
}

module.exports.dependencies = [`verifier`]
module.exports.tags = [`all`, `example`, `drop`]
