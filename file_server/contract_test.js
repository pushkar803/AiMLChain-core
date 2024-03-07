const path = require('path');
const MyContractABI = require(path.join(__dirname, '../build/contracts/UsingAiMLChain'))
const Web3 = require('web3');
const contract = require("truffle-contract");
const provider = new Web3.providers.HttpProvider("http://172.31.3.145:8545");
const web3 = new Web3(provider)

 async function xyz(){

   const accounts = await web3.eth.getAccounts();
   web3.eth.defaultAccount = accounts[0];
   const MyContract = contract(MyContractABI);
   MyContract.setProvider(provider);

   MyContract.deployed().then(function(instance) {
      return instance.requestPrediction(1, "QmVYNoE5dt8SDNu1YZMhFcdhmTgBAYdfzcysRkGQe9bCHH", 0,{from: accounts[0]})
   }).then(function(result) {
         console.log(result);
   
   }, function(error) {
         console.log(error);
   }); 

 }

 xyz()