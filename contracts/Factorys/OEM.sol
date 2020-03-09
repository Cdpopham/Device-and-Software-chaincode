pragma solidity ^0.4.24;

/**
 * @title OEM Factory
 * @dev Contract for deploying a device on chain
 */

import "./managed.sol";
import "./rolemanager.sol";
import "./registry.sol";
import "./device.sol";
import "./DRMToken.sol";

contract OEM is managed{
    address public owner;
    bytes32 public ORG;

    struct device{
     address license;
     bytes32 GenericHWHash;
     bytes32 modelName;
     bytes32 deviceType;
     bytes32 modelsku;
     }

    uint public deviceCount = 0 ;

    mapping(uint => device) public devices;


constructor(address _owner, bytes32 _ORG, address xManager,address xRegistryID) managed(xManager,xRegistryID) public {
  owner = _owner;
  ORG = _ORG;
  registryID = xRegistryID;
  manager = xManager;
}

function formatter(bytes32 _GenericHWHash, bytes32 _modelName, bytes32 _deviceType) private returns(bytes32) {
    if (_GenericHWHash == empty){emit Logger(logType.err , "missing GenericHWHash", _GenericHWHash, msg.sender); return 0x6d697373696e672047656e65726963485748617368;}
    if (_modelName == empty) {emit Logger(logType.err , "missing model Name", _modelName, msg.sender); return 0x6d697373696e67206d6f64656c204e616d65;}
    if (_deviceType == empty) {emit Logger(logType.err , "missing device Type", _deviceType, msg.sender); return 0x6d697373696e67206465766963652054797065;}
}

 function addDevice(bytes32 _GenericHWHash, bytes32 _modelName, bytes32 _deviceType, bytes32 _modelsku) public returns(bool success, address deployed, bytes32 error){

    error = formatter(_GenericHWHash,_modelName, _deviceType);
    if(error == empty){

    //make sure the device is unique
      require(registry(registryID).device(_GenericHWHash));

    //create a device contract
      Device genDevice = new Device(msg.sender, _GenericHWHash, _modelName, _deviceType, _modelsku, ORG);

    //store the data on new device
      device storage d = devices[deviceCount];
      d.GenericHWHash = _GenericHWHash;
      d.license = genDevice;
      d.modelName = _modelName;
      d.deviceType = _deviceType;
      d.modelsku = _modelsku;
      emit Logger(logType.statusUpdate, "Device Added", _GenericHWHash, msg.sender);
      deviceCount++;
      return (true, d.license, 0xc8);
    }
    return (false, 0x000000000000000000000000000000000000000, error);
  }

 function multiDevice(bytes32[] _GenericHWHash, bytes32[] _modelName, bytes32[] _deviceType, bytes32[] _modelsku) public returns(bool success){

    for(uint i=0; i<_GenericHWHash.length; i++){

     if(formatter(_GenericHWHash[i],_modelName[i], _deviceType[i])== true){


    //make sure the device is unique
      require(registry(registryID).device(_GenericHWHash[i]));

    //create a device contract
      Device genDevice = new Device(msg.sender, _GenericHWHash[i], _modelName[i], _deviceType[i],_modelsku[i], ORG);

    //store the data on new device
      device storage d = devices[deviceCount];
      d.GenericHWHash = _GenericHWHash[i];
      d.license = genDevice;
      d.modelName = _modelName[i];
      d.deviceType = _deviceType[i];
      d.modelsku = _modelsku[i];
      emit Logger(logType.statusUpdate, "Device Added", _GenericHWHash[i], genDevice);
      deviceCount++;
     }
     //loop
    }
  return true;
 }

 function deployCode(bytes _code) returns (address deployedAddress) {
    assembly {
      deployedAddress := create(0, add(_code, 0x20), mload(_code))
      jumpi(invalidJumpLabel, iszero(extcodesize(deployedAddress))) // jumps if no code at addresses
    }
    return deployedAddress;
  }
}
