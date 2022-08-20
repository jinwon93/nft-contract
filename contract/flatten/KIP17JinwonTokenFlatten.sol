pragma solidity  ^0.5.0;



interface IKIP13 {
    
    // @dev 계약이 정의된 인터페이스를 구현하는 경우 true 반환
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File : cotracts // IKIP17.sol



pragma solidity ^0.5.0;


contract IKIP17  is IKIP13 {

    event Tranfer(address indexed from , address indexed to , uint256 indexed tokenId);
    event Approval(address indexed owner , address indexed approved , uint256 indexed tokenId);
    event Tranfer(address indexed from , address indexed operator , uint256 indexed tokenId);



    // @dev NFT 소유자 계정의 수를 반환
    function balanceOf(address owner) pblic view returns (uint256 balance);


    // tokenId로 지정된 NFT 소유자로 반환
    function ownerOf(uint256 tokenId) pblic view returns (uint256 owner);

        function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
    
}