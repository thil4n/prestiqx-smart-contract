const EventManager = artifacts.require("EventManager");

module.exports = async function (deployer, network, accounts) {
    await deployer.deploy(EventManager, accounts[0]);
};
