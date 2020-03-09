pragma solidity ^0.4.24;

/**
 * @title Device
 * @dev Device proto contract, deployed by a device factory
 */

 import "./Tokens/DRMToken.sol";


contract Device{
  address   public Owner;
  bytes32 org; //owning org


  enum status{
      Manufactured,
      PKID Requested,
      Fulfilled,
      Activated,
      Returned,
      Refurbished,
      EOL,
      tbd0,
      tbd1,
      tbd2,
      tbd3,
      tbd4,
      tbd5
  }

  enum devType {
    notebook,
    desktop,
    mobile,
    tablet,
    gaming,
    IoT,
    server,
    other
  }

  status    public deviceStatus;
  //bool      public isActive;
  uint256   public startDate;
  uint256   public endDate;

  bytes32   public GenericHWHash; //Generic HW Hash [mandatory] (4KHash for the current OEM partners of Microsoft)
  bytes32   public modelName; //Model Name [mandatory]
  bytes32   public deviceType; // Device Type [mandatory] - Refer to Domain Data Deliverable for Device type
  bytes32   public modelSku; // Device SKU [optional]
  bytes32   public OEM; // oem that manufactured the device
  address   public OS; // device operation system contract

  enum logType {statusUpdate,err}
  event Logger(logType _type, string _memo, bytes32 _GenericHWHash,  address _device);

  //Enterprise enterprise;
  DRMToken DRMentitlement;

  struct ownerLog{
    address[] entitlements;
  }

  address[]  entitlements;
  mapping(address=> ownerLog)  ownerlogs;

  event newOwner(address _newOwner);
  event subscription(address _subscription);

/* local mapping of changes */

  //logical log record

  struct record {
    uint _date;         // timestamp
    status chStatus;    // status
    address chOwner;    // Owner
    address chOS;       // operating system
    string chMemo;      // human readable change detail
    bytes32 iteminfo;   // what item changed
  }

  // state mapping
  mapping(uint=>record) chLog;


  // kvs mapping

  mapping(bytes32=>bytes32) valueStore;
  bytes32[] public keys;

  function addKey(bytes32 _newKey, bytes32 _value) public returns(bool){
    keys.push(_newKey);
    valueStore[_newKey]= _value;
  }

  function readValue(bytes32 _refKey) public view returns(bytes32){
      return valueStore[_refKey];
  }

  function modValue(bytes32 _refKey, bytes32 _mod) public returns(bool){
      valueStore[_refKey] = _mod;
  }

  function keyLength() public view returns(uint){return keys.length;}

  function getKey(uint _n) public view returns(bytes32){
      return keys[_n];yes
  }

  // counter
  uint public chCnt;

// log a chcange
  function addChLog(status _chStatus, string _chMemo, bytes32 _itemInfo) public returns(bool success){
      record storage r = chLog[chCnt];
      r._date = now;
      r.chStatus = _chStatus;
      r.chOwner = Owner;
      r.chOS = OS;
      r.chMemo = _chMemo;
      r.iteminfo = _itemInfo;
      emit Logger(logType.statusUpdate, "Change log updated", _itemInfo, msg.sender);
      chCnt = chCnt + 1;
      return true;
  }
//retrieve a log record
  function getChLogs(uint _logs) public view returns(uint, status, address, address, string, bytes32){
      return (chLog[_logs]._date, chLog[_logs].chStatus, chLog[_logs].chOwner, chLog[_logs].chOS, chLog[_logs].chMemo, chLog[_logs].iteminfo);
  }

/* generate device
 * @dev  constructor that creates a device and assigns an owner
*/

 constructor(address _Owner, bytes32 _GenericHWHash, bytes32 _modelName, bytes32 _deviceType, bytes32 _modelSku, bytes32 _OEM) public {

     require(_GenericHWHash.length > 0
             && _modelName.length > 0
             && _deviceType.length > 0);

     GenericHWHash = _GenericHWHash;
     modelName = _modelName;
     deviceType = _deviceType;
     OEM = _OEM;
     OS = 0x0;

     Owner = _Owner;
     modelSku = _modelSku;

     deviceStatus = status.Manufactured;
     //startDate = now;
 }

/* change owners
 * @param newOwner: the new owner of the device
 * @dev this can only be called by the current owner
 */

 function transferOwner(address _newOwner) public returns (bool success){
     Owner = _newOwner;
     emit newOwner(_newOwner);
     return true;
 }

 function setOrg(bytes32 _org) public returns (bool success){
     org = _org;
     emit Logger(logType.statusUpdate, "Org Changed", _org , msg.sender);
     return true;
 }

function addOS(address _OS) returns(bool success){
      require(OS==0x0);
      OS = _OS;
      return true;
}



/* local store of tokens
 * a local list of subscribed tokens to keep a local balances
 * @dev onlyAdmin
 */

 function subscribe(address _entitlement) public returns (bool success){
     entitlements.push(_entitlement);
     emit Logger(logType.statusUpdate, "Software Added", 0x0 , _entitlement);
     return true;
 }

 /* local store of tokens
  * a local list of subscribed tokens to keep a local balances
  * @dev onlyAdmin
  */


 function statusUpdate(status _status) public returns (bool success){
    deviceStatus = _status;
    emit Logger(logType.statusUpdate, "Status Modified", 0x0 , msg.sender);
    return true;
 }

/*
  function unsubscribe(address _entitlement) public onlyAdmin returns (bool success){
      for(i = 0; i < entitlements.length; i++){
        if(entitlements[i] == _entitlement){
          entitlements[i] = "0x0000000000000000000000000000000000000001";
          }
      }
      emit Logger(logType.statusUpdate, "Software removed", 0x0 , _entitlement);

      return true;
  }
*/

/*
function clearAll() public onlyAdmin returns (bool success){
    entitlements = [];
    return true;
}
*/
/* get balance
 * get a devices balance for a entitlements
 * @param _entitlement : address of an entitlements
 */

 function getBalance(uint _entitlement) public view returns (uint256 deviceBalance, uint256 userBalance){
     address entitlementAddr = entitlements[_entitlement];
     DRMentitlement = DRMToken(entitlementAddr);
     deviceBalance = DRMentitlement.balanceOf(this);
     userBalance = DRMentitlement.balanceOf(Owner);
     return (deviceBalance, userBalance);
 }

 function transferEnt(uint _entitlement, address _to, uint _value) public returns (bool success){
     address entitlementAddr = entitlements[_entitlement];
     DRMentitlement = DRMToken(entitlementAddr);
     DRMentitlement.transfer(_to, _value);
     emit Logger(logType.statusUpdate, "Software Transferred", 0x0 , getEntitlement(_entitlement));
     return true;
 }


 function getEntitlement(uint _index) public view returns (address entitlement) {
    return entitlements[_index];
}
 function getEntitlementCount() public view returns (uint total) {
    return entitlements.length;
}

// erc721 safety

function onERC721Received(
  address _operator,
  address _from,
  uint256 _tokenId,
  bytes _data
)
  public
  returns(bytes4)
 {return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));}

}
