pragma solidity ^0.5.0;

import './SafeMath.sol';
import './AiMLChainStorageLib.sol';

/**
* @dev library functions to manage the native utility token for the 
* AiMLChain system.
*/
library AiMLChainTransferLib {

  using SafeMath for uint256;

  //ERC20 based Events
  event Approval(address indexed _owner, address indexed _spender, uint256 _value); 
  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  /**
  * @dev standard ERC-20 transfer for aiMLChainToken test
  */
  function transferTest(AiMLChainStorageLib.AiMLChainStorageStruct storage self, address _to, uint256 _value) internal returns(bool){
    _transfer(self, msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev standard ERC-20 transferFrom for aiMLChainToken test
  */
  function transferFromTest(AiMLChainStorageLib.AiMLChainStorageStruct storage self, address _from,address _to, uint256 _value) internal returns(bool){
    _transfer(self, _from, _to, _value);
    return true;
  }

  /**
  * @dev standard ERC-20 transfer  
  */
  function transfer(AiMLChainStorageLib.AiMLChainStorageStruct storage self, address _to, uint256 _value) internal returns(bool){
    _transfer(self, msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Standard ERC20 transferForm function 
  */
  function transferFrom(AiMLChainStorageLib.AiMLChainStorageStruct storage self, address _from, address _to, uint256 _value) 
    internal returns(bool) {
      require(self.allowances[_from][msg.sender] >= _value, "not allowed to transfer the specified amount");
      self.allowances[_from][msg.sender] -= _value;
      _transfer(self, _from, _to, _value);
  }

  /**
  * @dev helper to perform the ERC20 transfers
  */
  function _transfer(AiMLChainStorageLib.AiMLChainStorageStruct storage self, address _from, address _to, uint256 _value)
    internal {
      require(_value >= 0, "Transferring a non positive amount");
      require(balanceOf(self, _from) >= _value, "Insufficient transfer balance");
      self.balances[_from] -= _value;
      self.balances[_to] += _value;
      emit Transfer(_from, _to, _value);
  }

  /**
  * @dev standard ERC20 approve function 
  */
  function approve(AiMLChainStorageLib.AiMLChainStorageStruct storage self, address _spender, uint256 _value) internal returns(bool) {
    self.allowances[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
  * @dev standard ERC20 balanceOf helper
  */
  function balanceOf(AiMLChainStorageLib.AiMLChainStorageStruct storage self, address _owner) internal view returns(uint256){
    return self.balances[_owner];
  }

  /**
  * @dev standard ERC20 approval helper
  */
  function allowance(AiMLChainStorageLib.AiMLChainStorageStruct storage self, address _owner, address _spender) 
    internal view returns(uint256){
    return self.allowances[_owner][_spender];
  }
}