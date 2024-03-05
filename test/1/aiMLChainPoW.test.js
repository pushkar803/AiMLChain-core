const UsingAiMLChain = artifacts.require("UsingAiMLChain");
const AiMLChainMain = artifacts.require("AiMLChainMain");
const AiMLChainAbi = require("../../build/contracts/AiMLChain.json").abi;

contract("AiMLChainMain", async (accounts) => {
  let usingAiMLChain, aiMLChain;

  //const [alice, bob, john, mike, dave, chris] = accounts;

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
      from: accounts[0],
    });

    const vars = await aiMLChain.getCurrentVariables();
    const challenge = vars[0];
    const difficulty = vars[2];

    let res;

    for (let i = 1; i < 6; i++) {
      let nonce = 0;
      let target = BigInt(challenge) / BigInt(difficulty);
      result = BigInt("0x" + "f".repeat(64));
      while (result > target) {
        nonce++;
        result = BigInt(web3.utils.soliditySha3(challenge, accounts[i], nonce));
      }
      let data = web3.eth.abi.encodeFunctionCall(AiMLChainAbi[1], [1, 356, nonce]);
      res = await aiMLChain.sendTransaction({
        from: accounts[i],
        data,
      });
    }

    assert(res.logs[0].args.prediction.toNumber() === 356);
  });

  it("generates fresh supply of token as reward", async () => {
    let bal;
    for (let i = 1; i < 6; i++) {
      bal = await aiMLChain.balanceOf(accounts[i]);
      console.log("############# ", accounts[i])
      console.log(bal.toString())

      if (bal.toString() !== "50000000000000000000")
        assert(false, "Invalid balance.");
    }

    bal = await aiMLChain.totalSupply();
    assert(bal.toString() === "6250000000000000000000");
  });

  it("UsingAiMLChain receives the request", async () => {
    const res = await usingAiMLChain.getLatestResponse();
    assert(res.toNumber() === 356);
  });

  it("allows submission of another data", async () => {
    //Request for prediction through UsingAiMLChain contract
    const dataPoint = "QmTkzDwWqPbnAh5YiV5VwcTLnGdwSNsNTn2aDxdXBFca7D";
    const modelId = 1;
    const tip = 0;
    await usingAiMLChain.requestPrediction(modelId, dataPoint, tip, {
      from: accounts[0],
    });

    const vars = await aiMLChain.getCurrentVariables();
    const challenge = vars[0];
    const difficulty = vars[2];

    let res;

    for (let i = 1; i < 6; i++) {
      let nonce = 0;
      let target = BigInt(challenge) / BigInt(difficulty);
      result = BigInt("0x" + "f".repeat(64));
      while (result > target) {
        nonce++;
        result = BigInt(web3.utils.soliditySha3(challenge, accounts[i], nonce));
      }
      let data = web3.eth.abi.encodeFunctionCall(AiMLChainAbi[1], [2, 358, nonce]);
      //console.log(i);
      res = await aiMLChain.sendTransaction({
        from: accounts[i],
        data,
      });
    }

    //assert(res.logs[0].args.prediction.toNumber() === 358);
  });
});
