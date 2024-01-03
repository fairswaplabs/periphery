pragma solidity >=0.6.2;

import './IFairswapRouter02.sol';

interface IFairswapRouter is IFairswapRouter02 {
    function USDC() external pure returns (address);
    function rewardToken() external pure returns (address);
    function airdropPerUSDC() external pure returns (uint256);
    function totalAirdrop() external pure returns (uint256);
    function maxAirdrop() external pure returns (uint256);
    function startClaimTime() external pure returns (uint256);
    function getAirdrop(address owner) external pure returns (uint256);
    function isAirdropPair(address owner) external pure returns (bool);
}
