pragma solidity ^0.5.0;

import "./KIP17.sol";
// import "./roles/MinterRole.sol";


contract KIP17Mintable is KIP17, MinterRole {
    
    bytes4 private constant _INTERFACE_ID_KIP17_MINTABLE = 0xeab83e20;

    
    constructor () public {
        
        _registerInterface(_INTERFACE_ID_KIP17_MINTABLE);
    }

    
    function mint(address to, uint256 tokenId) public onlyMinter returns (bool) {
        _mint(to, tokenId);
        return true;
    }
}
