var simpleCoin = artifacts.require("simpleCoin");

module.exports = function(_deployer) {
  _deployer.deploy(simpleCoin);
};
