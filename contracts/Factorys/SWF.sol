pragma solidity ^0.4.24;

/**
 * @title Software Factory
 * @dev Contract for deploying a software erc 721 on chain
 */

import "../managed.sol";
import "../registry.sol";
import "../Tokens/ERC721DRMToken.sol";

contract SWF is managed{

  address public owner;

    struct software{
     /* metadata */
     address addressK;
     string itemName;
     string icon;
     bytes32 partsNumber;
     string memo;
     }

    uint public swCount = 0 ;

    mapping(uint => software) public softwares;


constructor(address _owner, address xManager,address xRegistryID) managed(xManager,xRegistryID) public {
  owner = _owner;
  registryID = xRegistryID;
  manager = xManager;
}

 function addSoftware(string _itemName, string _icon, bytes32 _partsNumber, string memo ) public returns(bool success){


     require(registry(registryID).software(_partsNumber));

    //create a device contract
      ERC721DRMToken genSoftware = new ERC721DRMToken(_itemName, _icon, _partsNumber,  memo);

    //store the data on new device
      software storage s = softwares[swCount];
      s.addressK = genSoftware;
      s.itemName = _itemName;
      s.icon = _icon;
      s.partsNumber = _partsNumber;
      s.memo = memo;
      emit Logger(logType.statusUpdate, "Software Added", 0x0 , genSoftware);
      swCount++;
      return true;
    }
}
