var EthernalAccessControl = artifacts.require("./EthernalAccessControl.sol");

module.exports = function(deployer) {
  deployer.deploy(EthernalAccessControl);
};