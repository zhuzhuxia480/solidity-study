// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21 <0.9;

import "./IERC165.sol";

interface IERC1155Receiver is IERC165 {
    function onERC1155Received(address operator, address from, uint256 id, uint256 valude, bytes calldata data) external returns (bytes4);

    function onERC1155BatchReceived(address operator, address from, uint256[] calldata ids, uint256[] calldata values, bytes calldata data) external (bytes4);
}