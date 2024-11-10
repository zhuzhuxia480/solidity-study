// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21 <0.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract CrossChainToken is ERC20, Ownable {
    event Bridge(address indexed user, uint256 amount);
    event Mint(address indexed to, uint256 amount);

    constructor(string memory  name_, string   memory  symbol_, uint256 totalSupply) payable  ERC20(name_, symbol_) Ownable(msg.sender) {
        _mint(msg.sender, totalSupply);
    }

    function bridge(uint256 amount) public {
        _burn(msg.sender, amount);
        emit Bridge(msg.sender, amount);
    }

    function mint(address to, uint256 amount) public onlyOwner{
        _mint(to, amount);
        emit Mint(to, amount);
    }
}