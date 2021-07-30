
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract NerveSocial
{
    mapping(address => bytes32) public addressRegister;
    mapping(bytes32 => address) public nameRegister;
    

    event NameRegistered(address indexed user, bytes32 registeredName);
    event SocialRegistered(address indexed user, string[] output, uint256[] socialOutput);
    event LocationRegistered(address indexed user, uint256 latitude, uint256 longitude);  
    event UserBlacklisted(address indexed user, address userToBlacklist);
    
    
    /******************************************/
    /*       NerveSocial starts here         */
    /******************************************/


/**
    NameRegistered
    */
    function registerName(bytes32 registeredName) external
    {
        if (registeredName [0] != 0) 
        {
            require(nameRegister[registeredName] == address(0), "Name already taken.");
            bytes32 actualName;
            if (addressRegister[msg.sender] != 0) 
            {
                actualName = addressRegister[msg.sender]; 
                delete nameRegister[actualName];
            }
            addressRegister[msg.sender] = registeredName;
            nameRegister[registeredName] = msg.sender;

            emit NameRegistered(msg.sender, registeredName);
        }
    }


    /**
    SocialRegistered
    */
    function registerSocial(string[] memory registeredLink, uint256[] memory socialID) external
    {            
        uint256 arrayLength = registeredLink.length;
        string[] memory output = new string[](arrayLength);
        
        uint256 socialArrayLength = socialID.length;
        uint256[] memory socialOutput = new uint256[](socialArrayLength);
        emit SocialRegistered(msg.sender, output, socialOutput);
    }
    
    
    /**
    LocationRegistered
    */
    function setLocation(uint256 latitude, uint256 longitude) external
    {
        emit LocationRegistered(msg.sender, latitude, longitude);
    }


     /**
    UserBlacklisted
    */
    function setBlacklistUser(address userToBlacklist) external
    {
        emit UserBlacklisted(msg.sender, userToBlacklist);
    }
}
