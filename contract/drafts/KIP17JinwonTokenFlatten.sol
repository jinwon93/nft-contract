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


     function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _tokenOwner[tokenId];
        require(owner != address(0), "KIP17: owner query for nonexistent token");

        return owner;
    }


     function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner, "KIP17: approval to current owner");

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "KIP17: approve caller is not owner nor approved for all"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }


    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "KIP17: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }


    function setApprovalForAll(address to, bool approved) public {
        require(to != msg.sender, "KIP17: approve to caller");

        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }


    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }


     function transferFrom(address from, address to, uint256 tokenId) public {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(msg.sender, tokenId), "KIP17: transfer caller is not owner nor approved");

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

     function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        transferFrom(from, to, tokenId);
        require(_checkOnKIP17Received(from, to, tokenId, _data), "KIP17: transfer to non KIP17Receiver implementer");
    }

      function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }


    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "KIP17: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }


     function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "KIP17: mint to the zero address");
        require(!_exists(tokenId), "KIP17: token already minted");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }


    function _burn(address owner, uint256 tokenId) internal {
        require(ownerOf(tokenId) == owner, "KIP17: burn of token that is not own");

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    function _burn(uint256 tokenId) internal {
        _burn(ownerOf(tokenId), tokenId);
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "KIP17: transfer of token that is not own");
        require(to != address(0), "KIP17: transfer to the zero address");

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }


    function _checkOnKIP17Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {
        bool success; 
        bytes memory returndata;

        if (!to.isContract()) {
            return true;
        }

        // Logic for compatibility with ERC721.
        (success, returndata) = to.call(
            abi.encodeWithSelector(_ERC721_RECEIVED, msg.sender, from, tokenId, _data)
        );
        if (returndata.length != 0 && abi.decode(returndata, (bytes4)) == _ERC721_RECEIVED) {
            return true;
        }

        (success, returndata) = to.call(
            abi.encodeWithSelector(_KIP17_RECEIVED, msg.sender, from, tokenId, _data)
        );
        if (returndata.length != 0 && abi.decode(returndata, (bytes4)) == _KIP17_RECEIVED) {
            return true;
        }

        return false;
    }

    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}   

pragma solidity ^0.5.0;


contract IKIP17Enumerable is IKIP17 {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) public view returns (uint256);
}


pragma solidity ^0.5.0;

contract KIP17Enumerable is KIP13, KIP17, IKIP17Enumerable {
    
    mapping(address => uint256[]) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;


    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;


    bytes4 private constant _INTERFACE_ID_KIP17_ENUMERABLE = 0x780e9d63;


    constructor () public {
        // register the supported interface to conform to KIP17Enumerable via KIP13
        _registerInterface(_INTERFACE_ID_KIP17_ENUMERABLE);
    }


    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        require(index < balanceOf(owner), "KIP17Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }


     function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }


    function tokenByIndex(uint256 index) public view returns (uint256) {
        require(index < totalSupply(), "KIP17Enumerable: global index out of bounds");
        return _allTokens[index];
    }


      function _transferFrom(address from, address to, uint256 tokenId) internal {
        super._transferFrom(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function _mint(address to, uint256 tokenId) internal {
        super._mint(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

      function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);

        _removeTokenFromOwnerEnumeration(owner, tokenId);
        // Since tokenId will be deleted, we can clear its slot in _ownedTokensIndex to trigger a gas refund
        _ownedTokensIndex[tokenId] = 0;

        _removeTokenFromAllTokensEnumeration(tokenId);
    }
 
    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {
        return _ownedTokens[owner];
    }

     function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }


     function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        

        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }        
        _ownedTokens[from].length--;

    }



    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        

        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 tokenIndex = _allTokensIndex[tokenId];

        
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        
        _allTokens.length--;
        _allTokensIndex[tokenId] = 0;
    }
}   


pragma solidity ^0.5.0;


contract IKIP17Metadata is IKIP17 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}



pragma solidity ^0.5.0;


contract KIP17Metadata is KIP13, KIP17, IKIP17Metadata {
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;



     bytes4 private constant _INTERFACE_ID_KIP17_METADATA = 0x5b5e139f;


     constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        
        _registerInterface(_INTERFACE_ID_KIP17_METADATA);
    }

     function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "KIP17Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        require(_exists(tokenId), "KIP17Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = uri;
    }


    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);

        // Clear metadata (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}    


pragma solidity ^0.5.0;



contract Ownable {
    address payable private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address payable) {
    return _owner;
    }

    modifier onlyOwner() {
    require(isOwner(), "Ownable: caller is not the owner");
    _;
    }


    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address payable newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}    


pragma solidity ^0.5.0;


library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


pragma solidity ^0.5.0;

contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }
      function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}


pragma solidity ^0.5.0;

library String {

  function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
    if (_i == 0) {
      return "0";
    }
    uint j = _i;
    uint len;
    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len - 1;
    while (_i != 0) {
      bstr[k--] = byte(uint8(48 + _i % 10));
      _i /= 10;
    }
    return string(bstr);
  }

}


pragma solidity ^0.5.0;


library MerkleProof {
    
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}


pragma solidity ^0.5.0;
contract KIP17Kbirdz is KIP17, KIP17Enumerable, KIP17Metadata, MinterRole {

    
    mapping (address => uint256) private _lastCallBlockNumber;
    uint256 private _antibotInterval;

    
    uint256 private _mintIndexForSale;

    uint256 private _mintLimitPerBlock;           
    uint256 private _mintLimitPerSale;            

    string  private _tokenBaseURI;
    uint256 private _mintStartBlockNumber;        
    uint256 private _maxSaleAmount;               
    uint256 private _mintPrice;                   

    string baseURI;
    string notRevealedUri;
    bool public revealed = false;
    bool public publicMintEnabled = false;



     function _baseURI() internal view returns (string memory) {
      return baseURI;
    }

    function _notRevealedURI() internal view returns (string memory) {
      return notRevealedUri;
    }

    function setBaseURI(string memory _newBaseURI) public onlyMinter {
      baseURI = _newBaseURI;
    }

    function setNotRevealedURI(string memory _newNotRevealedURI) public onlyMinter {
      notRevealedUri = _newNotRevealedURI;
    }

    function reveal(bool _state) public onlyMinter {
      revealed = _state;
    }

    function tokenURI(uint256 tokenId)
      public
      view
      returns (string memory)
    {
      require(
        _exists(tokenId),
        "KIP17Metadata: URI query for nonexistent token"
      );
      
      if(revealed == false) {
        string memory currentNotRevealedUri = _notRevealedURI();
        return bytes(currentNotRevealedUri).length > 0
            ? string(abi.encodePacked(currentNotRevealedUri, String.uint2str(tokenId), ".json"))
            : "";
      }
      string memory currentBaseURI = _baseURI();
      return bytes(currentBaseURI).length > 0
          ? string(abi.encodePacked(currentBaseURI, String.uint2str(tokenId), ".json"))
          : "";
    }


    constructor () public {
      
      _mintIndexForSale = 1;
    }

    function withdraw() external onlyMinter{
      
      0x3e944Ca8B08a0a0D3245B05ABF01586B9142f52C.transfer(address(this).balance * 5 / 100);
      
      msg.sender.transfer(address(this).balance);
      
    }

    function mintingInformation() external view returns (uint256[7] memory){
      uint256[7] memory info =
        [_antibotInterval, _mintIndexForSale, _mintLimitPerBlock, _mintLimitPerSale, 
          _mintStartBlockNumber, _maxSaleAmount, _mintPrice];
      return info;
    }

    function setPublicMintEnabled(bool _state) public onlyMinter {
      publicMintEnabled = _state;
    }

    function setupSale(uint256 newAntibotInterval, 
                       uint256 newMintLimitPerBlock,
                       uint256 newMintLimitPerSale,
                       uint256 newMintStartBlockNumber,
                       uint256 newMintIndexForSale,
                       uint256 newMaxSaleAmount,
                       uint256 newMintPrice) external onlyMinter{
      _antibotInterval = newAntibotInterval;
      _mintLimitPerBlock = newMintLimitPerBlock;
      _mintLimitPerSale = newMintLimitPerSale;
      _mintStartBlockNumber = newMintStartBlockNumber;
      _mintIndexForSale = newMintIndexForSale;
      _maxSaleAmount = newMaxSaleAmount;
      _mintPrice = newMintPrice;
    }


    function publicMint(uint256 requestedCount) external payable {
      require(publicMintEnabled, "The public sale is not enabled!");
      require(_lastCallBlockNumber[msg.sender].add(_antibotInterval) < block.number, "Bot is not allowed");
      require(block.number >= _mintStartBlockNumber, "Not yet started");
      require(requestedCount > 0 && requestedCount <= _mintLimitPerBlock, "Too many requests or zero request");
      require(msg.value == _mintPrice.mul(requestedCount), "Not enough Klay");
      require(_mintIndexForSale.add(requestedCount) <= _maxSaleAmount + 1, "Exceed max amount");
      require(balanceOf(msg.sender) + requestedCount <= _mintLimitPerSale, "Exceed max amount per person");

      for(uint256 i = 0; i < requestedCount; i++) {
        _mint(msg.sender, _mintIndexForSale);
        _mintIndexForSale = _mintIndexForSale.add(1);
      }
      _lastCallBlockNumber[msg.sender] = block.number;
    }

    //Whitelist Mint
    bytes32 public merkleRoot;
    mapping(address => bool) public whitelistClaimed;
    bool public whitelistMintEnabled = false;

    function setMerkleRoot(bytes32 _merkleRoot) public onlyMinter {
      merkleRoot = _merkleRoot;
    }

    function setWhitelistMintEnabled(bool _state) public onlyMinter {
      whitelistMintEnabled = _state;
    }



     function whitelistMint(uint256 requestedCount, bytes32[] calldata _merkleProof) external payable {
      require(whitelistMintEnabled, "The whitelist sale is not enabled!");
      require(msg.value == _mintPrice.mul(requestedCount), "Not enough Klay");
      require(!whitelistClaimed[msg.sender], 'Address already claimed!');
      require(requestedCount > 0 && requestedCount <= _mintLimitPerBlock, "Too many requests or zero request");
      bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
      require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), 'Invalid proof!');

      for(uint256 i = 0; i < requestedCount; i++) {
        _mint(msg.sender, _mintIndexForSale);
        _mintIndexForSale = _mintIndexForSale.add(1);
      }

      whitelistClaimed[msg.sender] = true;
    }

    //Airdrop Mint
    function airDropMint(address user, uint256 requestedCount) external onlyMinter {
      require(requestedCount > 0, "zero request");
      for(uint256 i = 0; i < requestedCount; i++) {
        _mint(user, _mintIndexForSale);
        _mintIndexForSale = _mintIndexForSale.add(1);
      }
    }
}