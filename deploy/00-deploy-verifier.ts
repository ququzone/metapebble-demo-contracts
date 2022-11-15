module.exports = async ({ ethers, getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    log(`Deploying MetapebbleDataVerifier...`)
    const deployResult = await deploy("MetapebbleDataVerifier", {
        from: deployer,
        proxy: {
            proxyContract: "OpenZeppelinTransparentProxy",
            execute: {
                methodName: "initialize",
                args: [["0x8896780a7912829781f70344ab93e589dddb2930"]],
            },
        },
        log: true,
        deterministicDeployment: false,
    })
    if (deployResult.newlyDeployed) {
        log(
            `contract MetapebbleDataVerifier deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`
        )
    }
}

module.exports.tags = [`all`, `verifier`]
