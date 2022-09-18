// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IReward {
    event ConfigChanged(address registryAddress, address tokenAddress, bool tokenLaunched);
    event KlayClaimed(address user, uint256 amount);
    event TokenClaimed(address user, uint256 amount);
    event RewardGiven(address user, uint256 klayAmount, uint256 tokenAmount);

    function claimKlay() external;
    function claimToken() external;
    function claimAll() external;

    function giveReward(address _address, uint256 _klayAmount, uint256 _tokenAmount) external;

    function changeConfig(address _registryAddress, address _tokenAddress, bool _tokenLaunched) external;
}
