var PreimageVerifier = artifacts.require("./PreimageVerifier.sol");
var SolnPreimageVerifier = artifacts.require("./SolnPreimageVerifier.sol");

module.exports = function (deployer) {
  deployer.deploy(PreimageVerifier).then(() => deployer.deploy(SolnPreimageVerifier, PreimageVerifier.address));
};
