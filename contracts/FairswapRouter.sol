pragma solidity =0.6.6;

import './interfaces/IFairswapRouter.sol';
import './interfaces/IFairswapFactory.sol';
import './interfaces/IERC20.sol';
import './libraries/SafeMath.sol';
import './FairswapRouter02.sol';
import './Ownable.sol';

contract FairswapRouter is IFairswapRouter, FairswapRouter02, Ownable {
    using SafeMath for uint256;
    uint256 public constant BASE_DIVISOR = 10 ** 4;
    address public override rewardToken;
    address public override USDC;
    uint256 public override airdropPerUSDC;
    uint256 public override totalAirdrop;
    uint256 public override maxAirdrop;
    uint256 public override startClaimTime;
    mapping(address => uint256) public override getAirdrop;
    mapping(address => bool) public override isAirdropPair;

    event RewardAdded(address user, uint256 amount, uint256 total);
    event RewardClaimed(address user, uint256 amount);

    constructor(
        address _factory,
        address _WETH,
        address _USDC,
        address _rewardToken,
        uint256 _airdropPerUSDC,
        uint256 _maxAirdrop,
        uint256 _startClaimTime
    ) public FairswapRouter02(_factory, _WETH) {
        USDC = _USDC;
        rewardToken = _rewardToken;
        airdropPerUSDC = _airdropPerUSDC;
        maxAirdrop = _maxAirdrop;
        startClaimTime = _startClaimTime;
    }

    function _swap(uint[] memory amounts, address[] memory path, address _to) internal virtual override {
        super._swap(amounts, path, _to);
        if (totalAirdrop < maxAirdrop) {
            address pairInput = FairswapLibrary.pairFor(factory, path[0], path[1]);
            address pairOutput = FairswapLibrary.pairFor(factory, path[path.length - 2], path[path.length - 1]);
            if (isAirdropPair[pairInput] || isAirdropPair[pairOutput]) {
                uint256 amount;
                if (path[0] == USDC) {
                    amount = amounts[0];
                } else if (path[path.length - 1] == USDC) {
                    amount = amounts[amounts.length - 1];
                }
                amount = amount.mul(airdropPerUSDC) / BASE_DIVISOR;
                getAirdrop[msg.sender] = getAirdrop[msg.sender].add(amount);
                totalAirdrop = totalAirdrop.add(amount);
                emit RewardAdded(msg.sender, amount, getAirdrop[msg.sender]);
            }
        }
    }

    function claim() public {
        if(block.timestamp >= startClaimTime){
            uint256 airdrop = getAirdrop[msg.sender];
            if(airdrop > 0){
                getAirdrop[msg.sender] = 0;
                IERC20(rewardToken).transfer(msg.sender, airdrop);
                emit RewardClaimed(msg.sender, airdrop);
            }
        }
    }

    function setAirdropPerUSDC(uint256 _airdropPerUSDC) external onlyOwner {
        airdropPerUSDC = _airdropPerUSDC;
    }

    function setAirdropPair(address _tokenA, address _tokenB, bool _status) external onlyOwner {
        address pair = IFairswapFactory(factory).getPair(_tokenA, _tokenB);
        require(pair != address(0), "no pair");
        isAirdropPair[pair] = _status;
    }

    function setMaxAirdrop(uint256 _maxAirdrop) external onlyOwner{
        maxAirdrop = _maxAirdrop;
    }

    function setStartClaimTime(uint256 _startClaimTime) external onlyOwner{
        startClaimTime = _startClaimTime;
    }

    function setUSDC(address _USDC) external onlyOwner{
        USDC = _USDC;
    }

    function setReawrdToken(address _rewardToken) external onlyOwner{
        rewardToken = _rewardToken;
    }
}
