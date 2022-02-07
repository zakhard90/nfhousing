// migrating the appropriate contracts
var NFHousingToken = artifacts.require("./NFHousingToken.sol");
var Verifier = artifacts.require("./Verifier.sol");
var SolnPreimageVerifier = artifacts.require("./SolnPreimageVerifier.sol");

module.exports = function (deployer) {
  deployer.deploy(Verifier);
  deployer.deploy(SolnPreimageVerifier);
  deployer.deploy(NFHousingToken, "NFHousing", "NFH");
};
