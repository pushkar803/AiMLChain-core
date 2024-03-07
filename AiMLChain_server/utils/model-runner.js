const { PythonShell } = require("python-shell");
const dotenv = require('dotenv');
dotenv.config();
var ipfsAPI = require('ipfs-api')
var ipfs = ipfsAPI(`${process.env.CHAIN_HOST}`, '5001', {protocol: 'http'}) // leaving out the arguments will default to these values
const fs = require('node:fs');
const path = require('path');
const crypto = require('crypto');

//For local testing
const data = {
  1: "image_classify.py",
  2: "cat_or_dog.py",
};

async function getPrediction(modelId, dataPoint) {
  tempResp = await ipfs.get(dataPoint)
  filedata = tempResp[0].content

  const currentDate = new Date();
  const timestamp = currentDate.getTime();
  const randomString = crypto.createHash('md5').update(String(timestamp)).digest('hex');
  const filename = `${randomString}.jpg`;

  const outputPath = path.join(__dirname+"/../models/", filename);
  
  fs.writeFile(outputPath, filedata, err => {
    if (err) {
      console.error(err);
    } 
  });
  
  const prediction = await new Promise((resolve, reject) => {
    PythonShell.run(
      `./AiMLChain_server/models/${data[modelId]}`,
      { args: outputPath },
      function (err, result) {
        if (err) reject(err);
        fs.rmSync(outputPath, {
            force: true,
        });
        if (result && result.length > 0) {
          if(modelId == 1)
            resolve(result[0])
          else if(modelId == 2)
            resolve(result[1])
        }else{
          resolve("Something went wrong, Please try again ...")
        }
      }
    );
  });

  return prediction;
}

async function downloadFile(cid, outputPath) {
  const content = [];
  for await (const chunk of ipfs.cat(cid)) {
    content.push(chunk);
  }
  fs.writeFileSync(outputPath, Buffer.concat(content));
}

module.exports = { getPrediction };

// getPrediction(2,"QmVYNoE5dt8SDNu1YZMhFcdhmTgBAYdfzcysRkGQe9bCHH").then((resp)=>{
//   console.log(resp)
// })
