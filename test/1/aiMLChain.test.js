const UsingAiMLChain = artifacts.require("UsingAiMLChain");
const AiMLChainMain = artifacts.require("AiMLChainMain");
const BN = require("bn.js");
const AiMLChainAbi = require("../../build/contracts/AiMLChain.json").abi;

contract("AiMLChain", async (accounts) => {
  let usingAiMLChain, aiMLChain;

  const [alice, bob, john, mike, dave, chris] = accounts;

  it("is deployed properly", async () => {
    aiMLChain = await AiMLChainMain.deployed();
    usingAiMLChain = await UsingAiMLChain.deployed();

    assert(aiMLChain.address !== "");
    assert(usingAiMLChain.address !== "");
  });

  it("allows submission of data", async () => {
    //Request for prediction through UsingAiMLChain contract
    const dataPoint = "QmTkzDwWqPbnAh5YiV5VwcTLnGdwSNsNTn2aDxdXBFca7D";
    const modelId = 1;
    const tip = 0;
    await usingAiMLChain.requestPrediction(modelId, dataPoint, tip, {
      from: alice,
    });

    //Miners (5) submits data
    const data = web3.eth.abi.encodeFunctionCall(AiMLChainAbi[2], [1, 356]);
    await aiMLChain.sendTransaction({
      from: bob,
      data,
    });
    await aiMLChain.sendTransaction({
      from: john,
      data,
    });
    await aiMLChain.sendTransaction({
      from: mike,
      data,
    });
    await aiMLChain.sendTransaction({
      from: chris,
      data,
    });
    const result = await aiMLChain.sendTransaction({
      from: dave,
      data,
    });

    assert(result.logs[0].args.prediction.toNumber() === 356);
  });

  it("UsingAiMLChain receives the request", async () => {
    const res = await usingAiMLChain.getLatestResponse();
    assert(res.toNumber() === 356);
  });
});
