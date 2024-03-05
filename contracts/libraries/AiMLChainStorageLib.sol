pragma solidity ^0.5.0;

/**
* @dev Library to define the storage type for Eternal Storage Pattern
*/

library AiMLChainStorageLib{

  struct Error {
    uint256 errorType; //0: Invalid datapoint, 1: invalid request hash (No such dataset/model)
    bool hasError;
  }

  struct Request {
    string dataPoint;

    address caller;

    uint256 modelId; 
    uint256 requestId;
    uint256 predictionsReceived; //newBlock on 5th prediction
    uint256[5] finalValues;
    
    address[5] miners;
  
    bool isValid;

    mapping(address => bool) minersSubmitted;
    
    //keccak256("birth") - required for request aging
    //keccak256("tip")
    //keccak256("requestQPosition")
    mapping(bytes32 => uint256) uintStorage;
  }

  struct AiMLChainStorageStruct{
    mapping(bytes32 => uint) uintStorage;
    mapping(bytes32 => address) addressStorage;

    bytes32 currentChallenge;

    uint256[] requestQ;

    mapping(uint256 => Request) requestIdToRequest;
    //Token Vars
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
  }

  function updateImplementation(AiMLChainStorageStruct storage self, address _newImpl) internal {
    require(msg.sender == self.addressStorage[keccak256('owner')], "Not authorised.");
    self.addressStorage[keccak256('aiMLChainAddress')] = _newImpl;
  }

  function setOwner(AiMLChainStorageStruct storage self, address _newOwner) internal {
    require(msg.sender == self.addressStorage[keccak256('owner')], "Not authorised.");
    self.addressStorage[keccak256('owner')] = _newOwner;
  }
}