var ArtifactOwnership = artifacts.require("./ArtifactOwnership.sol");

module.exports = function(deployer) {
  deployer.deploy(ArtifactOwnership);
};
