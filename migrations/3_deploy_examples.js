const AlwaysExecutableJob = artifacts.require("AlwaysExecutableJob");
const SimpleCronJob = artifacts.require("SimpleCronJob");

module.exports = function (deployer) {
    deployer.deploy(AlwaysExecutableJob);
    deployer.deploy(SimpleCronJob);
};