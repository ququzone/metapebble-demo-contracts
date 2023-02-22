module.exports = async ({ ethers, getNamedAccounts, deployments }) => {
    const { deploy, get, log } = deployments
    const { deployer } = await getNamedAccounts()

    log(`Deploying OpenStreetMapNFT...`)
    let deployResult = await deploy("OpenStreetMapNFT", {
        from: deployer,
        log: true,
        args: [],
        deterministicDeployment: false,
    })
    if (deployResult.newlyDeployed) {
        log(
            `contract OpenStreetMapNFT deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`
        )
    }
}

module.exports.tags = [`all`, `nft`, `openstreetmap`]
