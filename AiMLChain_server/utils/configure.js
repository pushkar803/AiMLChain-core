const Web3 = require("web3");
const AiMLChainProxy = require("../../build/contracts/AiMLChainMain.json");
const AiMLChain = require("../../build/contracts/AiMLChain.json");

async function init() {
  const web3 = new Web3("ws://localhost:8545");

  const networkId = await web3.eth.net.getId();
  const aiMLChainInstance = new web3.eth.Contract(
    AiMLChainProxy.abi,
    AiMLChainProxy.networks[networkId].address
  );
  return {
    web3,
    aiMLChainAbi: AiMLChain.abi,
    aiMLChain: aiMLChainInstance,
  };
}

module.exports = {
  init,
};
