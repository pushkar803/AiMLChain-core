pragma solidity ^0.5.0;

import './AiMLChainStorageLib.sol';
import './AiMLChainTransferLib.sol';
import './SafeMath.sol';

/**
* @dev library functions for AiMLChain.sol 
*/
library AiMLChainLib {

  //Constants for storage access
  bytes32 public constant requestCount = 0x05de9147d05477c0a5dc675aeea733157f5092f82add148cf39d579cafe3dc98;
  bytes32 public constant birth = 0x0f3fe971129295ad98fb77108128ec4c94083ec495d6ae9d7f14797c097eba91;
  bytes32 public constant tip = 0x9c35b68a5d39a44a5834c87c06e0905b483f5921b1cdeb093ce2cca2a2349a4c;
  bytes32 public constant difficulty = 0xb12aff7664b16cb99339be399b863feecd64d14817be7e1f042f97e3f358e64e;
  bytes32 public constant requestQPosition = 0x1e344bd070f05f1c5b3f0b1266f4f20d837a0a8190a3a2da8b0375eac2ba86ea;
  bytes32 public constant currentRequestId = 0x7584d7d8701714da9c117f5bf30af73b0b88aca5338a84a21eb28de2fe0d93b8;
  bytes32 public constant lastCheckpoint = 0xde51f251916b3aa9a2c8ba3c001731c4a7abf4ab61324f8fa182ed1b3aca750e;
  bytes32 public constant expiryThreshold = 0xf3b61ed74195ed072c4bce5b03aa99fc9ea41769bc3c650e65bb794e49281734;
  bytes32 public constant totalSupply = 0x7c80aa9fdbfaf9615e4afc7f5f722e265daca5ccc655360fa5ccacf9c267936d;
  bytes32 public constant reward = 0x594d34f771ec633c2f562d96c03f9299763555317b87ad49b1aa8c08079dde0e;
  bytes32 public constant requestsInQ = 0x9d35db82da5d0cf70eb254e4850bba2332d9a0dd52374be5ffb3866e6f97269b;

  //Events
  event NewBlock(uint256 id, uint256 prediction, uint256 nonce); 
  event ReceivedRequest(uint256 id, string datapoint, uint256 tip);

  //Testing events
  event Test1(uint256 prediction);

  /**
  * @notice 
  * @dev init_test sets up the genesis block and loads the proxy main with the initial mine.
  * this init is specifically for the aiMLChainToken testing.
  */
  function initTest(AiMLChainStorageLib.AiMLChainStorageStruct storage self) internal returns(bool) {
    //Uncomment in main
    self.balances[address(this)] = 2**256 - 1;

    // to test- aiMLChainPoW 
    self.currentChallenge = 0x289783b359a8ceaae95ebfc22d20253fd65753dd61e63796c88ab8f1f2f582d7;
    self.uintStorage[difficulty] = 500;

    // raw testing tokens
    self.balances[0x7CD86862A4AAA9E701CF255c2cE00fF13d50AD6F] = 1000 * 10**18;
    self.balances[0x4B5dB76845B70fE426cF82014D67A778931F62c7] = 1000 * 10**18;
    self.balances[0x184fb4e5FCe775244f2C5dEFEedF73f71c3351DD] = 1000 * 10**18;
    self.balances[0xc1A215d9355967d36D78248A57b6308D36aF4b25] = 1000 * 10**18;
    self.balances[0x4e150E015077eb2eF6cA1e9D66da81ca04729fDa] = 1000 * 10**18;
    self.balances[0xA7e2DADf5ca04C01Cc06307be44fA5543909FfBB] = 1000 * 10**18;

    self.uintStorage[totalSupply] = 6000 * 10**18;
    self.uintStorage[reward] = 50 * 10 ** 18;
    self.uintStorage[requestsInQ] = 0;
  } 

  /**
  * @dev Sends the final prediction to the user contract and derives the new challenge. Also 
  * adjusts the difficulty
  */
  function newBlock(AiMLChainStorageLib.AiMLChainStorageStruct storage self, uint256 _id, uint256 _nonce) internal returns(bool){
    
    AiMLChainStorageLib.Request storage request = self.requestIdToRequest[_id];

    //Simple difficulty adjustment.
    if(now - self.uintStorage[lastCheckpoint] < 15 seconds) {
      self.uintStorage[difficulty]++;
    } else {
      self.uintStorage[difficulty] = SafeMath.max(1, self.uintStorage[difficulty] - 1);
    }

    uint256 prediction = 0;
    uint256 cmax = 0;
    for(uint256 i = 0; i < 2; i++) {
      uint256 count = 0;
      for(uint256 j = 0; j < 2; j++) {
        if(request.finalValues[i] == request.finalValues[j])
          count++;
      }
      if(count > cmax){
        cmax = count;
        prediction = request.finalValues[i];
      }
    }

    //Call the user contract
    (bool result, ) = request.caller.call(abi.encodeWithSignature("requestCallback(uint256,uint256)", _id, prediction));
    require(result, "Low level call failed!");

    //Pay reward to generate new supply
    for(uint i = 0; i < 2; i++) {
      AiMLChainTransferLib.transferFromTest(self, address(this), request.miners[i], request.uintStorage[tip] / 2 + self.uintStorage[reward]);
    }
    self.uintStorage[totalSupply] += 250 * 10 ** 18;

    //update variables
    request.isValid = false;
    delete self.requestIdToRequest[_id];

    self.uintStorage[requestsInQ]--;

    if(self.uintStorage[requestsInQ] != 0) {
      self.uintStorage[lastCheckpoint] = now;
      self.currentChallenge = keccak256(abi.encodePacked(self.currentChallenge, _nonce, blockhash(block.number - 1)));
      self.uintStorage[currentRequestId] = _getTopId(self);
    } else {
      self.uintStorage[currentRequestId] = 0;
    }

    emit NewBlock(_id, prediction, _nonce);

    return true;
  }

  /**
  * @dev utility function to retrieve the top funded ID from the 
  */
  function _getTopId(AiMLChainStorageLib.AiMLChainStorageStruct storage self) internal returns(uint256 topId) {
    uint256 maxPri = 0;
    uint256 maxIndex = 0; //Records current max priority 
    for(uint i = 0; i < self.requestQ.length; i++) {
      if((self.requestIdToRequest[self.requestQ[i]].uintStorage[tip] + (now - self.requestIdToRequest[self.requestQ[i]].uintStorage[birth])) > maxPri && self.requestIdToRequest[self.requestQ[i]].isValid){
        maxPri = self.requestIdToRequest[self.requestQ[i]].uintStorage[tip];
        maxIndex = i;
      }
    }
    topId = self.requestQ[maxIndex];
    self.requestIdToRequest[topId].uintStorage[requestQPosition] = maxIndex;
  }

  /**
  * @dev User contract can call this to add a request to the queue, along with a tip.
  * @param _modelId id of the model whose prediction we want
  * @param _dataPoint IPFS hash of the dataPoint 
  * @param _tip tip value in tokens. 0 for initial testing.
  */
  function requestPrediction(AiMLChainStorageLib.AiMLChainStorageStruct storage self, uint256 _modelId, string memory _dataPoint, uint256 _tip) internal returns(uint256){
    
    self.uintStorage[requestCount]++;
    uint256 id = self.uintStorage[requestCount];

    AiMLChainStorageLib.Request memory request;
    self.requestIdToRequest[id] = request;

    AiMLChainStorageLib.Request storage newRequest = self.requestIdToRequest[id];

    newRequest.modelId = _modelId;
    newRequest.dataPoint = _dataPoint;
    newRequest.caller = msg.sender;
    newRequest.requestId = id;
    newRequest.uintStorage[birth] = now;
    newRequest.uintStorage[tip] = _tip;
    newRequest.uintStorage[requestQPosition] = self.requestQ.length;
    newRequest.isValid = true;

    if(self.uintStorage[requestsInQ] == 0) {
      self.uintStorage[lastCheckpoint] = now;
      self.uintStorage[currentRequestId] = id;
      self.currentChallenge = keccak256(abi.encodePacked(self.currentChallenge, newRequest.caller, blockhash(block.number - 1)));
    }

    // Insert the new request at the first invalidated postion or
    // if no pos available then insert at the end.
    bool isInserted = false;
    for(uint i = 0; i < self.requestQ.length; i++) {
      if(!self.requestIdToRequest[self.requestQ[i]].isValid){
        delete self.requestQ[i];
        self.requestQ[i] = id;
        isInserted = true;
        break;
      }
    }
    if(!isInserted)
      self.requestQ.push(id);

    self.uintStorage[requestsInQ]++;

    if(_tip != 0)
      AiMLChainTransferLib.transferFromTest(self, msg.sender, address(this), _tip); //Change to transferFrom for build.

    emit ReceivedRequest(id, _dataPoint, _tip);
    return id;
  }

  function submitMiningSolution(AiMLChainStorageLib.AiMLChainStorageStruct storage self, 
    uint256 _id, 
    uint256 _prediction,
    uint256 _nonce) internal{
    AiMLChainStorageLib.Request storage request = self.requestIdToRequest[_id];

    emit Test1(2563);

    require(!request.minersSubmitted[msg.sender], "Already submitted the value for the request.");

    _verifyNonce(self, _nonce);
  
    request.finalValues[request.predictionsReceived] = _prediction;
    request.minersSubmitted[msg.sender] = true;
    request.miners[request.predictionsReceived] = msg.sender;
    request.predictionsReceived++;

    if(request.predictionsReceived == 2) {
      newBlock(self, _id, _nonce);
    }
  }

  /**
  * @dev helper function to verify the correctness of the nonce value sent in by the miners.
  */
  function _verifyNonce(AiMLChainStorageLib.AiMLChainStorageStruct storage self, uint256 _nonce) internal view {
    uint256 targetHashValue = uint256(self.currentChallenge) / self.uintStorage[difficulty];
    uint256 receivedUnderTargetHash = uint256(keccak256((abi.encodePacked(self.currentChallenge, msg.sender, _nonce))));
    require(targetHashValue > receivedUnderTargetHash, "Invalid nonce for the current challenge.");
  }

  /** 
  * Test function for AiMLChain.test.js
  */
  function submitMiningSolutionTest(AiMLChainStorageLib.AiMLChainStorageStruct storage self, uint256 _id, uint256 _prediction) internal{
    AiMLChainStorageLib.Request storage request = self.requestIdToRequest[_id];

    // TODO in main- Verify nonce
    request.finalValues[request.predictionsReceived] = _prediction;
    request.predictionsReceived++;

    if(request.predictionsReceived == 2) {
      //TODO in main- new block formation

      //Call the user contract
      (bool result, ) = request.caller.call(abi.encodeWithSignature("requestCallback(uint256,uint256)", _id, _prediction));
      require(result, "Low level call failed!");

      emit NewBlock(_id, _prediction, 0);
    }
  }
}