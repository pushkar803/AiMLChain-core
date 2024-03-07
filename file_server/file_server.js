const express = require('express');
const multer = require('multer');
const fs = require('fs');
const cors = require('cors'); // Require the CORS package
const dotenv = require('dotenv');
dotenv.config();
const path = require('path');

const app = express();
const port = 3002;
const host = '0.0.0.0'
const chainHost = `${process.env.CHAIN_HOST}`
const uploadDir = path.join(__dirname,'uploads');

const JSONdb = require('simple-json-db');
opFilePath = path.join(__dirname,'/output.json')
console.log(opFilePath)
jsonDb = new JSONdb(opFilePath);


const MyContractABI = require(path.join(__dirname, '../build/contracts/UsingAiMLChain'))
const Web3 = require('web3');
const contract = require("truffle-contract");
const provider = new Web3.providers.HttpProvider(`http://${chainHost}:8545`);
const web3 = new Web3(provider)

app.use(cors({
    origin: '*', // Allow all origins
    methods: ['GET', 'POST', 'DELETE', 'UPDATE', 'PUT', 'PATCH'], // Allow all methods
    allowedHeaders: ['Content-Type', 'Authorization', 'Origin', 'x-access-token', 'X-Requested-With', 'Accept'] // Allow all headers
  }));
  
var ipfsAPI = require('ipfs-api')
var ipfs = ipfsAPI(chainHost, '5001', {protocol: 'http'}) 

// Configure storage
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    uploadDirStr = uploadDir+"/"
    if (!fs.existsSync(uploadDirStr)) {
      fs.mkdirSync(uploadDirStr, { recursive: true });
    }
    cb(null, uploadDirStr);
  },
  filename: function (req, file, cb) {
    cb(null, file.fieldname + '-' + Date.now() + path.extname(file.originalname));
  }
});

const upload = multer({ storage: storage });
app.use("/app",express.static(path.join(__dirname,'/public')));

// Post API to upload image
app.post('/upload', upload.single('image'), (req, res) => {
  try {
    const filePath = path.join(uploadDir, req.file.filename);

        // Read the file
        fs.readFile(filePath, (err, fileData) => {

            if (err) {
            return res.status(500).send({
                message: 'Error reading file for IPFS upload',
                error: err.message
            });
            }

            // Upload the file to IPFS
            ipfs.add(Buffer.from(fileData), (error, result) => {

            if (error) {
                return res.status(500).send({
                    message: 'Error uploading file to IPFS',
                    error: error.message
                });
            }

            fs.unlink(filePath, (err) => {

                if (err) {
                    return res.status(500).send({
                        message: 'Error deleting the file after upload',
                        error: err.message
                    });
                }

                res.send({
                    message: 'Image uploaded successfully!',
                    result:result,
                    fileInfo: req.file
                });
            })
        })
    })

  } catch (error) {
    res.status(500).send({
      message: 'Error uploading image',
      error: error.message
    });
  }
});

app.get('/download', (req, res) => {
    const ipfsHash = req.query.hash;
  
    if (!ipfsHash) {
      return res.status(400).send({ message: 'IPFS hash is required' });
    }
  
    // Fetch the file from IPFS
    ipfs.get(ipfsHash, (error, files) => {
      if (error) {
        return res.status(500).send({
          message: 'Error fetching file from IPFS',
          error: error.message
        });
      }
  
      // files is an array of objects containing path and content
      // Assuming the hash points to a single file, not a directory
      if (files && files.length > 0 && files[0].content) {
        const fileContent = files[0].content;
  
        // Set appropriate headers for file download
        res.writeHead(200, {
          'Content-Disposition': `attachment; filename="${ipfsHash}.jpg"`, // You might want to set a more meaningful filename based on your application's context
          'Content-Type': 'application/octet-stream', // Adjust the content type according to your file's type
        });
  
        // Send the file content as response
        res.end(fileContent);
      } else {
        res.status(404).send({ message: 'File not found in IPFS' });
      }
    });
});

app.get('/callSmartContract', async (req, res) => {
  const ipfsHash = req.query.hash;

  if (!ipfsHash) {
    return res.status(400).send({ message: 'IPFS hash is required' });
  }

  try{

    result = await callSmartContract(ipfsHash)
    res.send({
      message: 'Success calling smart contrcat!',
      result:result
    })

  }  catch (error) {

    res.status(500).send({
      message: 'Error calling smart contrcat',
      error: error.message
    });

  }

})

app.get('/getPredictionForHash', async (req, res) => {
  
  const ipfsHash = req.query.hash;


  if (!ipfsHash) {
    return res.status(400).send({ message: 'IPFS hash is required' });
  }

  try{
    jsonDb = new JSONdb(opFilePath);

    result = jsonDb.get(ipfsHash);
    res.send({
      message: 'Success Getting Prediction For Hash!',
      result:result
    })

  }  catch (error) {

    res.status(500).send({
      message: 'Error Getting Prediction For Hash',
      error: error.message
    });

  }

})

app.listen(port, host, () => {
  console.log(`Server running at http://${host}:${port}`);
});


async function callSmartContract(ipfsHash){
  return new Promise(async (resolve, reject) => {
    const accounts = await web3.eth.getAccounts();
    web3.eth.defaultAccount = accounts[0];
    const MyContract = contract(MyContractABI);
    MyContract.setProvider(provider);

    MyContract.deployed().then(function(instance) {
      return instance.requestPrediction(1, ipfsHash, 0,{from: accounts[0]})
    }).then(function(result) {
      resolve(result);
    }, function(error) {
      resolve(error);
    }); 
  });
}

