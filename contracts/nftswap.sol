// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21 <0.9;

interface IERC165 {
    /**
     * @dev 如果合约实现了查询的`interfaceId`，则返回true
     * 规则详见：https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     *
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    )external returns(bytes4);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed opreator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata datga) external ;
    function safeTransferFrom(address from, address to, uint256 tokenId) external ;
    function transferFrom(address from, address to, uint256 tokenId)external ;
    function approve(address to, uint256 tokenId)external ;
    function setApprovalForAll(address owner, address operator) external view returns (bool);
    function getApproved(uint256 tokenId)external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

contract NFTSwap is IERC721Receiver {

    event List(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 price);
    event Purchase(address indexed buyer, address nftAddr, uint256 indexed tokenId, uint256 price);
    event Revoke(address indexed seller, address nftAddr, uint256 indexed tokenId);
    event Update(address indexed seller, address nftAddr, uint256 indexed tokenId, uint256 price);

    struct Order {
        address owner;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Order)) public nftList;
    fallback() external payable {}
    receive() external payable {}

    function list(address _nftAddr, uint256 _tokenId, uint256 _price) external {
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.getApproved(_tokenId) == address(this), "Need Approved");
        require(_price > 0);
        Order storage _order = nftList[_nftAddr][_tokenId];
        _order.owner = msg.sender;
        _order.price = _price;

        _nft.safeTransferFrom(msg.sender, address(this), _tokenId);
        emit List(msg.sender, _nftAddr, _tokenId, _price);
    }

    function purchase(address _nftAddr, uint256 _tokenId) public payable {
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(_order.price > 0, "Invalid Price");
        require(msg.value >= _order.price, "Need more token");
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order");

        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        //向卖家发送eth，这里的eth来自msg.value
        payable(_order.owner).transfer(_order.price);
        payable(msg.sender).transfer(msg.value-_order.price);

        delete nftList[_nftAddr][_tokenId];

        emit Purchase(msg.sender, _nftAddr, _tokenId, _order.price);
    }


    function revoke(address _nftAddr, uint256 _tokenId) public {
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(_order.owner == msg.sender, "Not owner");
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order");

        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        delete nftList[_nftAddr][_tokenId];
        emit Revoke(msg.sender, _nftAddr, _tokenId);
    }

    function update(address _nftAddr, uint256 _tokenId, uint256 _newPrice) public {
        require(_newPrice > 0, "Invalid Price");
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(_order.owner == msg.sender, "Not Owner");
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid owner");
        _order.price = _newPrice;
        emit Update(msg.sender, _nftAddr, _tokenId, _newPrice);
    }


    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    )external override pure  returns(bytes4){
        return IERC721Receiver.onERC721Received.selector;
    }
}