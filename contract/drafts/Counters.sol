pragma solidity ^0.5.0;




library Counters {


    using SafeMath for uint256;


    struct Counter {
        uint256 _value; // default : 0 
    }

    function current(Counter storage counter) internal view returns (uint256){
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value;
    }

    function decrement ( Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}


pragma solidity ^0.5.0;



contract KIP13 is IKIP13 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_KIP13 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for KIP13 itself here
        _registerInterface(_INTERFACE_ID_KIP13);
    }

    /**
     * @dev See `IKIP13.supportsInterface`.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "KIP13: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}    


pragma solidity ^0.5.0;



contract KIP17 is KIP13, IKIP17 {
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;


    
    bytes4 private constant _KIP17_RECEIVED = 0x6745782b;

    
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    
    mapping (uint256 => address) private _tokenOwner;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to number of owned token
    mapping (address => Counters.Counter) private _ownedTokensCount;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;


     bytes4 private constant _INTERFACE_ID_KIP17 = 0x80ac58cd;

    constructor () public {
        
        _registerInterface(_INTERFACE_ID_KIP17);
    }

    
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "KIP17: balance query for the zero address");

        return _ownedTokensCount[owner].current();
    }
}   