// migrating the appropriate contracts
var Verifier = artifacts.require("./Verifier.sol");
var SolnPreimageVerifier = artifacts.require("./SolnPreimageVerifier.sol");

module.exports = function (deployer) {
  deployer.deploy(Verifier).then(() => deployer.deploy(SolnPreimageVerifier, Verifier.address));
};
