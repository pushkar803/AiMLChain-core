const Miner = require("./utils/miner");
//const level = require("level");
const {displayTable, displayTablePredResult} = require("./utils/display");
const configure = require("./utils/configure");
const BN = require("bn.js");
const modelRunner = require("./utils/model-runner");
const CryptoJS = require("crypto-js");
const fs = require('fs');
const JSONdb = require('simple-json-db');
const path = require('path');


opFilePath = path.join(__dirname,'/../file_server/output.json')
const jsonDb = new JSONdb(opFilePath);

//Get reference to database store. To prevent mutex locks this is commented.
//const db = level("./AiMLChain_server/model_store");

//Initialize miner
var miner;

var isMining = false;

function startEventListener({ web3, aiMLChain, aiMLChainAbi }) {
  aiMLChain.events
    .ReceivedRequest({})
    .on("data", () => handleNewRequest({ web3, aiMLChain, aiMLChainAbi }));
  aiMLChain.events
    .NewBlock({})
    .on("data", () => handleNewBlock({ web3, aiMLChain, aiMLChainAbi }));
}

function handleNewRequest({ web3, aiMLChain, aiMLChainAbi }) {
  if (!isMining) {
    checkAndMine({ web3, aiMLChain, aiMLChainAbi });
  }
}

function handleNewBlock({ web3, aiMLChain, aiMLChainAbi }) {
  if (isMining) {
    isMining = false;
    console.log("*--New block formed--*");
    checkAndMine({ web3, aiMLChain, aiMLChainAbi });
  }
}

async function checkAndMine({ web3, aiMLChain, aiMLChainAbi }) {
  console.log("**---Waiting to fetch requests--**");

  const canGetVars = await aiMLChain.methods.canGetVariables().call();
  if (canGetVars) {
    startMining({ web3, aiMLChain, aiMLChainAbi });
  }
}

async function getVariables({ aiMLChain }) {
  const vars = await aiMLChain.methods.getCurrentVariables().call();
  return {
    challenge: vars[0],
    id: vars[1],
    difficulty: vars[2],
    modelId: vars[3],
    dataPoint: vars[4],
  };
}

async function submitMiningSolution({
  web3,
  aiMLChain,
  aiMLChainAbi,
  id,
  prediction,
  nonce,
}) {
  try {
    const tx = await web3.eth.sendTransaction({
      to: aiMLChain.options.address,
      data: web3.eth.abi.encodeFunctionCall(aiMLChainAbi[1], [
        id,
        prediction,
        nonce,
      ]),
      gas: 10000000,
    });

    console.log("Successfully submitted solution for request id: ", id);
  } catch (err) {
    console.log(
      "Transaction failed (no panic): Block is already mined by 5 miners / nonce submitted is invalid / you have already sumbitted the data for this"
    );
  }
}

async function startMining({ web3, aiMLChain, aiMLChainAbi }) {
  const { challenge, id, difficulty, modelId, dataPoint } = await getVariables({
    aiMLChain,
  });

  isMining = true;

  // console.log("*-------------Started Mining-------------*");
  // displayTable({ id, challenge, difficulty });

  jsonDb.set(dataPoint, "");
  let prediction = await modelRunner.getPrediction(modelId, dataPoint);

  const nonce = await miner.findUnderTargetHash(
    web3,
    new BN(challenge.slice(2), 16),
    new BN(difficulty, 10)
  );

  // console.log("Found POW solution: ", nonce);
  const ophash = CryptoJS.MD5(nonce).toString();

  // console.log("Prediction for given request: ",  id, prediction, nonce);
  console.log(`*-------------Prediction for Request Id: ${id}-------------*`);
  displayTablePredResult({ id, prediction, ophash });

  opData = JSON.stringify({
    "prediction":prediction,
    "nonce":nonce
  })
  jsonDb.set(dataPoint, opData);

  prediction = 1
  await submitMiningSolution({ web3, aiMLChain, aiMLChainAbi, id, prediction, nonce }); 
}


(async () => {
  const { web3, aiMLChain, aiMLChainAbi } = await configure.init();
  try{
    const accounts = await web3.eth.getAccounts();
    miner = new Miner(accounts[process.argv[2]]);
    web3.eth.defaultAccount = accounts[process.argv[2]];
    startEventListener({ web3, aiMLChain, aiMLChainAbi });
    checkAndMine({ web3, aiMLChain, aiMLChainAbi });
  }catch(e){
    console.log('####################')
    console.log(e)
  }

})();

process.on('unhandledRejection', (reason, promise) => {
  console.log('Unhandled Rejection at:', promise, 'reason:', reason);
});
