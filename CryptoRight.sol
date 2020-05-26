pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/drafts/Counters.sol";
import "./ICryptoRight.sol";

contract CryptoRight is ICryptoRight {
    using Counters for Counters.Counter; 
    
    Counters.Counter copyright_ids;
    
    struct Work {
        address owner;
        string uri;
    }
    
    mapping(uint => Work) public copyrights;
    
    event Copyright(uint copyright_id, address owner, string reference_uri);
    
    event OpenSource(uint copyright_id, string reference_uri);
    
    event Transfer(uint copyright_id, address new_owner);
    
    modifier onlyCopyrightOwner(uint copyright_id) {
        require(copyrights[copyright_id].owner == msg.sender, "You do not have permission to alter this copyright!" );
        _;
    }
    
    function copyrightWork(string memory reference_uri) public {
        copyright_ids.increment(); // generate a new copyright_id
        uint id = copyright_ids.current();
        
        // map the copyright_id to the Work struct containing the given uri and the msg.sender
        // who ever calls this will be the copyright owner
        copyrights[id] = Work(msg.sender, reference_uri);
        
        emit Copyright(id, msg.sender, reference_uri);
    }
    
    function openSourceWork(string memory reference_uri) public {
        // follow similar steps as above, BUT we don't map copyright_id using msg.sender
        // We just map the copyright_id to an uri and map it to address 0(no owner)
        copyright_ids.increment(); 
        uint id = copyright_ids.current();
        
        // no need to set address(0) in the copyrights mapping as this is already the default for empty address types
        copyrights[id].uri = reference_uri;
        
        emit OpenSource(id, reference_uri);
    }
    function transferCopyrightOwnership(uint copyright_id, address new_owner) public onlyCopyrightOwner(copyright_id) {
        // Re-maps given copyright_id to a new copyright_id owner.
        copyrights[copyright_id].owner = new_owner;
        
        emit Transfer(copyright_id, new_owner);
    }
    
    function renounceCopyrightOwnership(uint copyright_id) public onlyCopyrightOwner(copyright_id) {
        transferCopyrightOwnership(copyright_id, address(0));
        
        emit OpenSource(copyright_id, copyrights[copyright_id].uri);
    }
}
// Contract Address: 0xD6770B3AEa04ca29150981Cc4cD76EDD8Ef64EE3