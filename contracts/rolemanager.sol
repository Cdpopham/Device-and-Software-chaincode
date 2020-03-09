pragma solidity ^0.4.24;


/**
 * @title Role Manager
 * @dev System wide role management on chain; Only admin are allowed to change roles
 */

contract roleManager{

    struct user{
        bool    isAdmin;
        bool    isOEM;
        bool    isSoftware;
        bool    isUser;
        bytes32  org;
    }

    //internal mapping of public address to user struct
    mapping(address => user) public users;

    modifier onlyAdmin{
        require(users[msg.sender].isAdmin == true);
        _;
    }

    constructor()public {users[msg.sender].isAdmin = true;}

/* change user roles */

  /** 0x3fa286b9 === bytes4(keccak256('chUser(address)'))
    * @dev assign an address as an enterprise user in the system
    * @param _newUser  address of user whose role will either be elevated or revoked
    * @return bool success or fail; if fail emit event logger
    */
    function chUser(address _newUser) onlyAdmin public returns(bool success){
        users[_newUser].isUser = !users[_newUser].isUser;
        return true;
    }

    /** 0x64136c55 === bytes4(keccak256('chSoftware(address)'))
     * @dev assign an address as a software developer in the system
     * @param _newUser  address of user whose role will either be elevated or revoked
     * @return bool success or fail; if fail emit event logger
     */
    function chSoftware(address _newUser) onlyAdmin public returns(bool success){
        users[_newUser].isSoftware = !users[_newUser].isSoftware;
        return true;
    }

    /** 0x3fa286b9 === bytes4(keccak256('chOEM(address)'))
     * @dev assign an address as an OEM in the system
     * @param _newUser  address of user whose role will either be elevated or revoked
     * @return bool success or fail; if fail emit event logger
     */
    function chOEM(address _newUser) onlyAdmin public returns(bool success){
        users[_newUser].isOEM = !users[_newUser].isOEM;
        return true;
    }

    /** 0x24d7806c === bytes4(keccak256('chAdmin(address)'))
     * @dev assign an address as an Administrator in the system
     * @param _newUser  address of user whose role will either be elevated or revoked
     * @return bool success or fail; if fail emit event logger
     */
    function chAdmin(address _newUser) onlyAdmin public returns(bool success){
        users[_newUser].isAdmin = !users[_newUser].isAdmin;
        return true;
    }

    /** 0x0ffa86919 === bytes4(keccak256('chOrg(address)'))
     * @dev assign an address as an enterprise user in the system
     * @param _newUser  address of user whose role will either be elevated or revoked
     * @return bool success or fail; if fail emit event logger
     */
    function chOrg(address _newUser, bytes32 _org) onlyAdmin public returns (bool success){
        users[_newUser].org = _org;
        return true;
    }


    /*@Dev role checks */
     * Functional checking for address rolls
     * @Params Address of User or contract to check
     * @returns t/f
     * '0x24d7806c': bytes4(keccak256('isAdmin(address)'),
     * '0xaa9d20de': bytes4(keccak256('isOEM(address)'),
     * '0xcd4fdea9': bytes4(keccak256('isOrg(address,bytes32)'),
     * '0x548014c7': bytes4(keccak256('isSoftware(address)'),
     * '0x4209fff1': bytes4(keccak256('isUser(address)'),
     * '0xa87430ba': bytes4(keccak256('users(address)')
    */
    function isUser(address _user) public view returns(bool success){require(users[_user].isUser);return true;}
    function isSoftware(address _user) public view returns(bool success){require(users[_user].isSoftware);return true;}
    function isOEM(address _user) public view returns(bool){require(users[_user].isOEM);return true;}
    function isAdmin(address _user) public view returns(bool){require(users[_user].isAdmin);return true;}
    function isOrg(address _user, bytes32 _org) public view returns(bool){require(users[_user].org == _org); return true;}
}
