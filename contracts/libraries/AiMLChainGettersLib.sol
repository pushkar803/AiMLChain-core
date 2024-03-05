pragma solidity ^0.5.0;

import './SafeMath.sol';
import './AiMLChainStorageLib.sol';

/**
* @dev logic for the getter functions present in AiMLChainStorage contract
*/
library AiMLChainGettersLib {
  using SafeMath for uint256;

  function getAddressStorage(AiMLChainStorageLib.AiMLChainStorageStruct storage self, bytes32 _data) internal view returns(address){
      return self.addressStorage[_data];
  }

  function getUintStorage(AiMLChainStorageLib.AiMLChainStorageStruct storage self, bytes32 _data) internal view returns(uint){
      return self.uintStorage[_data];
  }

  function getCurrentVariables(AiMLChainStorageLib.AiMLChainStorageStruct storage self) internal view returns(
    bytes32, uint256, uint256, uint256, string memory
  ) {
    return (
      self.currentChallenge,
      self.uintStorage[keccak256('currentRequestId')],
      self.uintStorage[keccak256('difficulty')],
      self.requestIdToRequest[self.uintStorage[keccak256('currentRequestId')]].modelId,
      self.requestIdToRequest[self.uintStorage[keccak256('currentRequestId')]].dataPoint
    );
  }

  function canGetVariables(AiMLChainStorageLib.AiMLChainStorageStruct storage self) internal view returns(bool) {
    return self.uintStorage[keccak256('requestsInQ')] != 0;
  }

  function totalSupply(AiMLChainStorageLib.AiMLChainStorageStruct storage self) internal view returns(uint256) {
    return self.uintStorage[keccak256('totalSupply')];
  }
}