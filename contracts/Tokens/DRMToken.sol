pragma solidity ^0.4.24;

/**
 * @title DRM token from Alpha
 * @dev ERC 20 like token from Alpha phase of project,
 */


import "../Utils/safemath.sol";

contract DRMToken is SafeMath {


  enum productType{
    subscription,
    perpetual
  }

  string public name;
  string public icon;
  uint8 public decimals;
  uint256 totalSupply;

  string productDeveloper;
  productType types;
  string public version;

  uint public exDate;
  uint time = now;

//map any address to a balance
  mapping (address => uint256) public balances;

/*
 * events
 */
  event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
  event newMint(uint value);
  event burnNotice(address burner, uint value, bytes data);

// only operate if the entitlement is not expired
  modifier notExpired(){
    if(exDate !=0){
      require(now < exDate);
      }
    _;
  }

/*
 * Constructor function
 * @dev this is called by a software licensor who then becomes the owner
 * @param name: the name of the product
 * @param icon : icon url
 * @param decimals : not used for bool tokens can be used for consumption
 * @param initial supply : tokens at start, stored at owners addresses
 * @param experation_date : date after which the entitlement will stop functioning.
*/

 constructor(string _name, string _icon, uint8 _decimals, uint256 _initialSupply, uint expiration_Date, string _version) public {
      balances[msg.sender] = _initialSupply;
      totalSupply = _initialSupply;
      name = _name;
      icon = _icon;
      decimals = _decimals;
      exDate = expiration_Date;
      version = _version;
  }

  /*
   * Function that is called to mint new tokens
   * @param value: how many coins to make
   * @dev can only be called by the owner, sends minted tokens to the owner address
   */

  function mint(uint value) public notExpired returns (bool success){
    totalSupply = add(totalSupply, value);
    balances[msg.sender] = add(balances[msg.sender], value);
    emit newMint(value);
    return true;
  }

/*
 * function called to burn tokens
 * @param value : how many to burnNotice
 * @param data : a byte string if a user wants to add some kind of hex message
 */
   function burns(uint _value, bytes _data) public returns (bool success){
    if (balanceOf(msg.sender) < _value) revert();
    balances[msg.sender] = sub(balanceOf(msg.sender), _value);
    totalSupply = sub(totalSupply, _value);
    emit burnNotice(msg.sender, _value, _data);
    return true;
}

  /* Function that is called when a user or another contract wants to transfer funds
   * @param to : address to transfer a balance to
   * @param value : how many units to send
   * @dev only happens if msg sender has a balance and the entitlement is not expired
   */
  function transfer(address _to, uint _value) public notExpired returns (bool success) {
    bytes memory empty;
    return transferToAddress(_to, _value, empty);
}

  /* function that is called when transaction target is an address
   *
   * @dev internal function
   */
  function transferToAddress(address _to, uint _value, bytes _data) private notExpired returns (bool success) {
    if (balanceOf(msg.sender) < _value) revert();
    balances[msg.sender] = sub(balanceOf(msg.sender), _value);
    balances[_to] = add(balanceOf(_to), _value);
    emit Transfer(msg.sender, _to, _value, _data);
    return true;
  }


  /*
   * getter: returns balance of an addresses
   * @param owner: address that we want to know a balance of
   */
  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}
