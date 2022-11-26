var simpleCoin = artifacts.require("simpleCoin");

module.exports = function(_deployer) {
  _deployer.deploy(simpleCoin, "0x9EdD560f3E1132A44b29201Eb26613e9B6045A58");
};
