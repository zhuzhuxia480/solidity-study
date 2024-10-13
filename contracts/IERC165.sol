// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21 <0.9;

/**
 * ERC165 standard interface
 */
interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}