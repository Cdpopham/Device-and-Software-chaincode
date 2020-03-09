pragma solidity 0.4.24;

/**
 * @title Registry
 * @dev System wide registry management on the chain;
 *  this requires the role manager to be deployed first.
 *  Current live contract: 0x27c8170b19647b1e8d8c6f6cbff9658f7ce57765
 */

import "./managed.sol";

contract registry is managed{

  // mapping of device id to t/f
    mapping(bytes32 => bool) devices;

  //mapping of pkid to t/f value
    mapping(bytes32 => bool) PKID;

    constructor(address xManager, address xRegistryID) managed(xManager,xRegistryID) public {
    }

    /** 0xf37013c9 === bytes4(keccak256('bytes2string(bytes32)'))
     * @dev global device id registry
     *        takes any bytes32 input and creates a bool maping. each can only be used once
     * @param _deviceID field cannot be empty and must be unique
     * @return bool success or fail; if fail emit event logger
     */

    function device(bytes32 _deviceID) public onlyOEM returns(bool success){
        bool test = devices[keccak256(_deviceID)];
        require(test == false);
        devices[keccak256(_deviceID)] = true;
        emit Logger(logType.statusUpdate, "Device Added", _deviceID, msg.sender);
        return true;
    }

    /**  0xad54f862 === bytes4(keccak256('string2bytes(string)'))
     * @dev global software id registry;
     *        takes any bytes32 input and creates a bool maping. each can only be used once
     * @param _PKID field cannot be empty and must be unique
     * @return bool success or fail; if fail emit event logger
     */

    function software(bytes32 _PKID) public onlySoftware returns(bool success){
        bool test = devices[keccak256(_PKID)];
        require(test == false);
        devices[keccak256(_PKID)] = true;
        emit Logger(logType.statusUpdate, "Software Added", _PKID, msg.sender);
        return true;
    }
}
