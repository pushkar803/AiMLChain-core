pragma solidity ^0.5.0;

import './AiMLChainStorage.sol';

/** 
* @title AiMLChain Main
* @dev Proxy contract to make delegate calls to the latest implementation
*/
contract AiMLChainMain is AiMLChainStorage{

  constructor(address _implAddress) public {
    //Todo: Call init()

    aiMLChain.initTest();
    aiMLChain.addressStorage[keccak256('aiMLChainAddress')] = _implAddress;
    aiMLChain.addressStorage[keccak256('owner')] = msg.sender;
  }

  //Event sharing
  event NewBlock(uint256 id, uint256 prediction, uint256 nonce);
  event ReceivedRequest(uint256 id, string datapoint, uint256 tip);

  /**
  * @dev Allows for implementation contract upgrades
  */
  function updateImplementation(address _newImpl) external {
    aiMLChain.updateImplementation(_newImpl);
  }

  /**
  * @dev sets the new owner
  */
  function setOwner(address _newOwner) external {
    aiMLChain.setOwner(_newOwner);
  }

  function() external payable {
    address _impl = aiMLChain.addressStorage[keccak256('aiMLChainAddress')];

    assembly {
      let ptr := mload(0x40)
      calldatacopy(ptr, 0, calldatasize)
      let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
      let size := returndatasize
      returndatacopy(ptr, 0, size)

      switch result
      case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }
}