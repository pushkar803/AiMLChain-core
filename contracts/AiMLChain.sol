pragma solidity ^0.5.0;

import './libraries/AiMLChainStorageLib.sol';
import './libraries/AiMLChainTransferLib.sol';
import './libraries/AiMLChainLib.sol';

/**
* @dev The main upgradeable implementation of AiMLChain. 
* This allows users to request for predictions, addTip to requests, and
* the miners can submit solutions.
*/
contract AiMLChain {

  using AiMLChainLib for AiMLChainStorageLib.AiMLChainStorageStruct;
  using AiMLChainTransferLib for AiMLChainStorageLib.AiMLChainStorageStruct;

  AiMLChainStorageLib.AiMLChainStorageStruct aiMLChain;

  /** 
  * @dev calls the library function to handle requests in AiMLChainLib
  */
  function requestPrediction(uint256 _modelId,string calldata _dataPoint,uint256 _tip) external returns(uint256){
    return aiMLChain.requestPrediction(_modelId, _dataPoint, _tip);
  }

  /**
  * @dev Allows miners to submit the requested prediction along with the POW nonce.
  */
  function submitMiningSolution(uint256 _id, uint256 _prediction, uint256 _nonce) external {
    aiMLChain.submitMiningSolution(_id, _prediction, _nonce);
  }

  /**
  * Test function to accept mining solution and requested prediction value.
  * Test written in aiMlChain.test.js
  */
  function submitMiningSolutionTest(uint256 _id, uint256 _prediction) external {
    aiMLChain.submitMiningSolutionTest(_id, _prediction);
  }

  /* Utility token functions */
  function name() external pure returns(string memory) {
    return "AiMLChain Token";
  }

  function symbol() external pure returns(string memory) {
    return "EML";
  }

  function decimals() external pure returns(uint256) {
    return 18;
  }

  /**
  * @dev for testing aiMlChainToken
  */
  function transferTest(address _to, uint256 _value) external returns(bool) {
    return aiMLChain.transferTest(_to, _value);
  }

   /**
  * @dev for testing aiMlChainToken
  */
  function transferFromTest(address _from, address _to, uint256 _value) external returns(bool) {
    return aiMLChain.transferFromTest(_from, _to, _value);
  }

  function transfer(address _to, uint256 _value) external returns(bool) {
    return aiMLChain.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) external returns(bool) {
    return aiMLChain.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) external returns(bool){
    return aiMLChain.approve(_spender, _value);
  }
}