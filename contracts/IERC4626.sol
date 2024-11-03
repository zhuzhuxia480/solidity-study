// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21 <0.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IERC4626 is IERC20, IERC20Metadata {
    
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(address indexed sender, address indexed receiver, address indexed owner, uint256 assets, uint shares);

    function asset() external view returns(address assetTokenAddress);

    function deposit(uint256 assets, address receiver) external returns(uint256 shares);
    function mint(uint256 shares, address receiver) external returns(uint256 assets);

    function withdraw(uint256 assets, address receiver, address owner) external returns(uint256 shars);
    function redeem(uint256 shares, address receiver, address owner) external returns(uint256 assets);
    function totalAssets() external view returns(uint256 totalManagedAssets);

    function convertToShares(uint256 assets) external view returns(uint256 shares);
    function convertToAssets(uint256 shares) external view returns(uint256 assets);
    function previewMint(uint256 shares) external view returns(uint256 assets);

    function previewWithdraw(uint256 assets) external view returns (uint256 shares);
    function previewRedeem(uint256 shares) external view returns (uint256 assets);
    function maxDeposit(address receiver) external view returns (uint256 maxAddress);
    function maxMint(address receiver) external view returns (uint256 maxShares);
    function maxWithdraw(address owner) external view returns (uint256 maxAssets);
    function maxRedeem(address owner) external view returns(uint256 maxShares);
}