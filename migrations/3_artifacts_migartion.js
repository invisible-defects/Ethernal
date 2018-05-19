var EthernalArtifacts = artifacts.require("./EthernalArtifacts.sol");

module.exports = function(deployer) {
  deployer.deploy(EthernalArtifacts);
};
