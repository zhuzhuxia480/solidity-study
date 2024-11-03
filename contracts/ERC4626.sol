// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21 <0.9;

import "./IERC4626.sol";
import {ERC20, IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC4626 is IERC4626, ERC20 {

    ERC20 private immutable _asset;
    uint8 private immutable _decimals;

    constructor(ERC20 asset_, string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        _asset = asset_;
        _decimals = asset_.decimals();
    }

    function asset() public view virtual override returns (address) {
        return address(_asset);
    }

    function decimals() public view virtual override(IERC20Metadata, ERC20) returns (uint8) {
        return _decimals;
    }

    function deposit(uint256 assets, address receiver) public virtual returns (uint256 shares) {
        shares = previewDepoist(assets);
        _asset.transferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assets, shares);
    }
    
    function mint(uint256 shares, address receiver) public virtual returns(uint256 assets) {
        assets = previewMint(shares); 
        _asset.transferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assets, shares);
    }

    function withdraw(uint256 assets, address receiver, address owner) public virtual returns (uint256 shares) {
        shares = previewWithdraw(assets);

        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }

        _burn(owner, shares);
        _asset.transfer(receiver, assets);
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    function redeem(uint256 shares, address receiver, address owner) public virtual returns (uint256 assets){
        assets = previewRedeem(shares);
        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }
        _burn(owner, shares);
        _asset.transfer(receiver, assets);
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    function totalAssets() public view virtual returns (uint256) {
        return _asset.balanceOf(address(this));
    }

    function convertToShares(uint256 assets) public view virtual returns (uint256){
        uint256 shares = totalSupply();
        return shares == 0 ? assets : assets * shares / totalAssets();
    }

    function convertToAssets(uint256 shares) public view virtual returns (uint256){
        uint256 supply  = totalSupply();
        return totalSupply() == 0 ? shares  : shares  * totalAssets() / supply;
    }

    function previewDepoist(uint256 assets) public view virtual returns (uint256){
        return convertToShares(assets);
    }

    function previewMint(uint256 shares) public view virtual returns(uint256 ) {
        return convertToAssets(shares);
    }
    
    function previewWithdraw (uint256 assets) public view virtual returns (uint256){
        return convertToShares(assets);
    }
 
    function previewRedeem(uint256 shares) public view virtual returns (uint256 ){
        return convertToAssets(shares);
    }

    function maxDeposit(address) public view virtual returns(uint256){
        return type(uint256).max;
    }

    function maxMint(address receivert) external view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxWithdraw(address owner) public view virtual returns (uint256){
        return convertToAssets(balanceOf(owner));
    }

    function maxRedeem( address owner) external view virtual returns (uint256 ){
        return balanceOf(owner);
    }
}
