var EthernalRating = artifacts.require("./EthernalRating.sol");

module.exports = function(deployer) {
  deployer.deploy(EthernalRating);
};
