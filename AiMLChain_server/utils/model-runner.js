const { PythonShell } = require("python-shell");
const ipfs = require("nano-ipfs-store").at("http://localhost:5001");

//For local testing
const data = {
  1: "weather.py",
};

async function getPrediction(modelId, dataPoint) {
  //const dataPointArgs = JSON.parse(await ipfs.cat(dataPoint));
  tempResp = await ipfs.cat(dataPoint)
  dataPointArgs = tempResp.split(",")

  // console.log("#####################################################################")
  // console.log(modelId, dataPointArgs)
  const prediction = await new Promise((resolve, reject) => {
    PythonShell.run(
      `./AiMLChain_server/models/${data[modelId]}`,
      { args: dataPointArgs },
      function (err, result) {
        if (err) reject(err);
        resolve(result[0]);
      }
    );
  });

  return prediction;
}

module.exports = { getPrediction };
