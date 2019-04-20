var SafeMath = artifacts.require("../contracts/SafeMath.sol");
var STO = artifacts.require("../contracts/STO.sol");
var Investor = artifacts.require("../contracts/Investor.sol");
var Divided = artifacts.require("../contracts/Divided.sol");


module.exports = function(deployer) {
    deployer.deploy(SafeMath)
        .then( () => deployer.deploy(STO))
        .then( () => deployer.deploy(Investor, STO.address))
        .then( () => deployer.deploy(Divided, Investor.address));
};
