// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21 <0.9;

import "./Address.sol";
import "./String.sol";
import "./IERC165.sol";
import "./IERC1155.sol";
import "./IERC1155MetadataURI.sol";
import "./IERC1155Receiver.sol";

contract ERC1155 is IERC1155, IERC165, IERC1155MetadataURI {
    using Address for address;
    using Strings for uint256;

    string public name;
    string public symbol;

    mapping(uint256 => mapping(address => uint256)) private _balance;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "address is not a valid owner");
        return _balance[id][account];
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids) external view virtual override returns (uint256[] memory) {
        uint256[] memory batchBalances = new uint256[](accounts.length);
        for(uint256 i = 0; i < accounts.length; ++i){
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }
        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(msg.sender != operator, "setting approval status for self");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public virtual override {
        address operator = msg.sender;
        require(from == operator || isApprovalForAll(from, operator), "caller is not token owner nor approved");
        require(to != address(0), "transfer to the zero address");
        uint256 fromBalance = _balance[id][from];
        require(fromBalance >= amount, "insufficient balance for transfer");
        unchecked {
            _balance[id][from] = fromBalance - amount;
        }
        _balance[id][to] += amount;
        emit TransferSingle(operator, form, to, id, amount);
        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public virtual override {
        address operator = msg.sender;
        require(from == msg.sender || isApprovalForAll(from, operator), "caller is not token owner not approved");
        require(to != address(0), "transfer to the zero address");

        for(uint256 i = 0; i < ids.length; ++i){
            uint256 id = ids[i];
            uint256 amount = amounts[i];
            uint256 fromBalance = _balance[id][from];
            require(fromBalance >= amount, "insufficient balance for transfer");
            unchecked{
                _balance[id][from] = fromBalance - amount;
            }
            _balance[id][to] += amount;
        }
        emit TransferBatch(operator, from, to, ids, amounts);
        _doSafeTransferAcceptanceCheck(operator, from, to, amount, data);
    }

    function _mint(address to, uint256 id, uint256 amount, bytes memory data) internal virtual {
        require(to != address(0), "mint to the zero address");
        address operator = msg.sender;
        _balance[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount, data);
        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual{
        require(to != address(0), "mint to the zero address");
        require(ids.length == amounts.length,"ids and amounts length mismatch");
        address operator = msg.sender;
        for(uint256 i = 0; i < ids.length; ++i){
            _balance[ids[i]][to] += amounts[i];
        }
        emit TransferBatch(operator, address(0), to, ids, amount);
        _doSafeTransferAcceptanceCheck(operator, from, to, amount, data);
    }

    function _burn(address from, uint256 id, uint256 amount) internal virtual {
        require(from != address(0), "burn from the zero address");
        address operator = msg.sender;
        uint256 fromBalance = _balance[id][form];
        require(fromBalance >= amount, "burn amount exceeds balance");
        unchecked {
            _balance[id][from] = fromBalance - amount;
        }
        emit TransferSingle(operator, form, address(0), id, amount);
    }

    function _burnBatch(address from, uint256[] memory ids, uint256[] memory amounts) internal virtual {
        require(from != address(0), "burn from the zero address");
        require(ids.length == amounts.length, "ids and amounts length mismatch");

        address operator = msg.sender;

        for(uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[id];
            uint256 amount = amounts[i];
            uint256 fromBalance = _balance[id][from];
            require(fromBalance >= amount, "burn amount exceeds balance");
            unchecked {
                _balance[id][from] = fromBalance - amount;
            }
        }
        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

    function _doSafeTransferAcceptanceCheck(address operator, address from, address to, uint256 id, uint256 amount, bytes memory data) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received()(operator, from, to, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }
    function uri(uint256 id) public view virtual override returns (string memory) {
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, id.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }
}




























