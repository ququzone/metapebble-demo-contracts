module.exports = async ({ ethers, getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    log(`Deploying GeneralFeeManager...`)
    let deployResult = await deploy("GeneralFeeManager", {
        from: deployer,
        log: true,
        args: ["1000000000000000000"],
        deterministicDeployment: false,
    })

    log(`Deploying VerifyFeeSelector...`)
    deployResult = await deploy("VerifyFeeSelector", {
        from: deployer,
        log: true,
        args: [deployResult.address],
        deterministicDeployment: false,
    })

    log(`Deploying MetapebbleDataVerifier...`)
    deployResult = await deploy("MetapebbleDataVerifier", {
        from: deployer,
        proxy: {
            proxyContract: "OpenZeppelinTransparentProxy",
            execute: {
                methodName: "initialize",
                args: [["0x0BDf1bc0cdD2E41E62E6BE2F756634FE2b587906"], deployResult.address],
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
