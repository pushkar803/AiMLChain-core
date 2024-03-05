const AiMLChainMain = artifacts.require("AiMLChainMain");
const UsingAiMLChain = artifacts.require("UsingAiMLChain");
const AiMLChainAbi = require("../../build/contracts/AiMLChain.json").abi;
const BN = require("bn.js");

contract("AiMLChainToken", async (accounts) => {
  let aiMLChain, usingAiMLChain;
  const [alice, bob, john, mike, dave, chris] = accounts;

  beforeEach(async () => {
    aiMLChain = await AiMLChainMain.deployed();
    usingAiMLChain = await UsingAiMLChain.deployed();
  });

  it("has tokens", async () => {

    

    const supply = await aiMLChain.totalSupply();

    
    const bal = await aiMLChain.balanceOf(alice);
    console.log("#############")
    console.log(bal.toString())

    assert(supply.toString() === "6000000000000000000000");
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


  it("allows transfer of tokens", async () => {
    const data = web3.eth.abi.encodeFunctionCall(AiMLChainAbi[6], [
      bob,
      new BN("10000000000000000000", 10),
    ]);
    await aiMLChain.sendTransaction({
      from: alice,
      data,
    });
    const bal = await aiMLChain.balanceOf(bob);
    
    assert(bal.toString() === "20000000000000000000");
  });

  // it("allows cross transfer of tokens", async () => {
  //   const data = web3.eth.abi.encodeFunctionCall(AiMLChainAbi[7], [
  //     bob,
  //     john,
  //     new BN("2000000000000000000000", 10),
  //   ]);
  //   await aiMLChain.sendTransaction({
  //     from: alice,
  //     data,
  //   });
  //   const bal = await aiMLChain.balanceOf(john);
  //   assert(bal.toString() === "3000000000000000000000");
  // });

  // it("allows tip transfers", async () => {
  //   const data = web3.eth.abi.encodeFunctionCall(AiMLChainAbi[6], [
  //     usingAiMLChain.address,
  //     new BN("1000000000000000000000", 10),
  //   ]);
  //   await aiMLChain.sendTransaction({
  //     from: john,
  //     data,
  //   });

  //   try {
  //     await usingAiMLChain.requestPrediction(1, "Hello", "500000000000000000000");
  //     assert(true);
  //   } catch (err) {
  //     assert(false);
  //   }
  // });
});
