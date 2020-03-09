pragma solidity 0.4.24;

/**
 * @title Managed
 * @dev role management modifiers, string mapping, and system wide fixed addresses
 */
import "./rolemanager.sol";

contract managed{
    address manager;
    address registryID;
    bytes32 empty = 0x0000000000000000000000000000000000000000000000000000000000000000;

    constructor(address _manager, address _registryID) public {
      manager = _manager;
      registryID = _registryID;
      }

    modifier onlyUser(){roleManager(manager).isUser(msg.sender); _;}
    modifier onlyOEM(){roleManager(manager).isOEM(msg.sender); _;}
    modifier onlySoftware(){roleManager(manager).isSoftware(msg.sender); _;}
    modifier onlyAdmin(){roleManager(manager).isAdmin(msg.sender); _;}
    modifier sameOrg(bytes32 _org){roleManager(manager).isOrg(msg.sender, _org); _;}

    /* logging */
    enum logType {statusUpdate,err}
    event Logger(logType _type, string _memo, bytes32 _deviceID,  address _device);

    /* string to byte functions */
    mapping(bytes32 => string) output;
    mapping(string => bytes32) bytesOutput;
    function bytes2string(bytes32 _data) public view returns(string rData){return output[_data];}
    function string2bytes(string _data) public view returns(bytes32 rData){return bytesOutput[_data];}


}
