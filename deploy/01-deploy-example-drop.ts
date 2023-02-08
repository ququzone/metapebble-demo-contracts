module.exports = async ({ ethers, getNamedAccounts, deployments }) => {
    const { deploy, get, log } = deployments
    const { deployer } = await getNamedAccounts()

    const verifier = await get("MetapebbleDataVerifier")

    log(`Deploying MetapebbleVerifiedDrop...`)
    let deployResult = await deploy("MetapebbleVerifiedDrop", {
        from: deployer,
        log: true,
        args: [
            120520000, // lat
            30400000, // long
            1000, // 1km
            verifier.address,
            "1000000000000000000"
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
