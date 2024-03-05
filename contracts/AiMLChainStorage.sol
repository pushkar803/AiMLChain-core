pragma solidity ^0.5.0;

import './libraries/SafeMath.sol';
import './libraries/AiMLChainStorageLib.sol';
import './libraries/AiMLChainGettersLib.sol';
import './libraries/AiMLChainTransferLib.sol';
import './libraries/AiMLChainLib.sol';

/**
* @title AiMLChain storage
* @dev Has external storage getter functions. 
* The logic resides in Transfer, Getters and Stake (in future) library. 
*/

contract AiMLChainStorage{

  using SafeMath for uint256;
  using AiMLChainGettersLib for AiMLChainStorageLib.AiMLChainStorageStruct;
  using AiMLChainStorageLib for AiMLChainStorageLib.AiMLChainStorageStruct;
  using AiMLChainTransferLib for AiMLChainStorageLib.AiMLChainStorageStruct;
  using AiMLChainLib for AiMLChainStorageLib.AiMLChainStorageStruct;

  AiMLChainStorageLib.AiMLChainStorageStruct aiMLChain;

  /**
  * @dev returns the address variables in the internal storage stored as
  * addressStorage[keccak('variableName')]
  */
  function getAddressStorage(bytes32 _data) external view returns(address) {
    return aiMLChain.getAddressStorage(_data);
  }

  /**
  * @dev returns the uint variables in the internal storage stored as
  * uintStorage[keccak('variableName')]
  */
  function getUintStorage(bytes32 _data) external view returns(uint256) {
    return aiMLChain.getUintStorage(_data);
  }

  /**
  * @dev returns all the variables necassary to serve a prediction request and
  * for a new system block.
  */
  function getCurrentVariables() external view returns(bytes32, uint256, uint256, uint256, string memory) {
    return aiMLChain.getCurrentVariables();
  }

  /**
  * @dev returns true if a new request is available to be served.
  * i.e currentRequestId != 0.
  */
  function canGetVariables() external view returns(bool) {
    return aiMLChain.canGetVariables();
  }
  
  /*ERC20 utility token helpers*/

  function balanceOf(address _owner) external view returns(uint256) {
    return aiMLChain.balanceOf(_owner);
  }

  function allowance(address _owner, address _spender) external view returns(uint256) {
    return aiMLChain.allowance(_owner, _spender);
  }

  function totalSupply() external view returns(uint256) {
    return aiMLChain.totalSupply();
  }
}