const Registry = artifacts.require("Registry");
const Reward = artifacts.require("Reward");

module.exports = function (deployer) {
    deployer.deploy(Registry);
    deployer.deploy(Reward);
};