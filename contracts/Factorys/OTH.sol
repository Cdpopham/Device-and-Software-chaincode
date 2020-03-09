pragma solidity ^0.4.24;

/**
 * @title Trash Factory(working title)
 * @dev Contract for deploying a device on chain
 */

import "../managed.sol";
import "../rolemanager.sol";
import "../registry.sol";
import "../device.sol";
import "../Tokens/DRMToken.sol";

contract oth is managed{
    address public owner;

    struct device{
     address license;
     address maker;
     bytes32 GenericHWHash;
     bytes32 modelName;
     bytes32 deviceType;
     bytes32 modelsku;
     }

    uint public deviceCount = 0 ;

    mapping(uint => device) public devices;


constructor(address _owner,address xManager,address xRegistryID) managed(xManager,xRegistryID) public {
  owner = _owner;
  registryID = xRegistryID;
  manager = xManager;
}

 function addDevice(bytes32 _modelName, bytes32 _deviceType, bytes32 _modelsku, bytes32 OEM) public returns(bool success){

     bytes32 _GenericHWHash = keccak256(abi.encodePacked(uint(_modelName),uint( _deviceType),uint(_modelsku)));

    //make sure the device is unique
    require(registry(registryID).device(_GenericHWHash));

    //create a device contract
      Device genDevice = new Device(msg.sender, _GenericHWHash, _modelName, _deviceType, _modelsku, OEM);

    //store the data on new device
      device storage d = devices[deviceCount];
      d.GenericHWHash = _GenericHWHash;
      d.license = genDevice;
      d.maker = msg.sender;

      d.modelName = _modelName;
      d.deviceType = _deviceType;
      d.modelsku = _modelsku;
      emit Logger(logType.statusUpdate, "Device Added", _GenericHWHash, msg.sender);
      deviceCount++;
      return true;
    }
  }
