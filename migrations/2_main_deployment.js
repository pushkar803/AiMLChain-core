const AiMLChainMain = artifacts.require("AiMLChainMain");
const AiMLChain = artifacts.require("AiMLChain");
const UsingAiMLChain = artifacts.require("UsingAiMLChain");

module.exports = function (deployer) {
  deployer.deploy(AiMLChain).then(() => {
    return deployer.deploy(AiMLChainMain, AiMLChain.address).then(() => {
      return deployer.deploy(UsingAiMLChain, AiMLChainMain.address);
    });
  });
};
