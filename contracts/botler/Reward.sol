// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../common/access/OwnableUpgradeable.sol";
import "../common/security/ReentrancyGuardUpgradeable.sol";
import "../common/token/IERC20Upgradeable.sol";
import "../common/token/utils/SafeERC20Upgradeable.sol";
import "./IReward.sol";

contract Reward is IReward, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public registryAddress;
    address public tokenAddress;
    bool public tokenLaunched;

    struct UserInfo {
        uint256 claimedKlay;
        uint256 vestedKlay;
        uint256 claimedToken;
        uint256 vestedToken;
    }

    mapping(address => UserInfo) public userInfo;

    function initialize(address _registryAddress, address _tokenAddress, bool _tokenLaunched, address _newOwner) external initializer {
        registryAddress = _registryAddress;
        tokenAddress = _tokenAddress;
        tokenLaunched = _tokenLaunched;

        __Ownable_init();
        transferOwnership(_newOwner);
    }

    function claimKlay() external override nonReentrant {
        _claimKlay(msg.sender);
    }

    function claimToken() external override nonReentrant {
        _claimToken(msg.sender);
    }

    function claimAll() external override nonReentrant {
        _claimKlay(msg.sender);
        _claimToken(msg.sender);
    }

    function _claimKlay(address _address) internal {
        UserInfo storage user = userInfo[_address];
        uint256 claimable = user.vestedKlay - user.claimedKlay;
        user.claimedKlay = user.claimedKlay + claimable;
        require(address(this).balance >= claimable, "ERR:NOT_ENOUGH_BALANCE");
        payable(_address).transfer(claimable);
        emit KlayClaimed(_address, claimable);
    }

    function _claimToken(address _address) internal {
        require(tokenLaunched);
        UserInfo storage user = userInfo[msg.sender];
        uint256 claimable = user.vestedToken - user.claimedToken;
        uint256 bal = IERC20Upgradeable(tokenAddress).balanceOf(address(this));
        require(bal >= claimable);

        user.claimedToken = user.claimedToken + claimable;
        IERC20Upgradeable(tokenAddress).transfer(_address, claimable);
        emit TokenClaimed(msg.sender, claimable);
    }

    function giveReward(address _address, uint256 _klayAmount, uint256 _tokenAmount) external override nonReentrant {
        require(msg.sender == registryAddress);
        UserInfo storage user = userInfo[_address];

        user.vestedKlay = user.vestedKlay + _klayAmount;
        user.vestedToken = user.vestedToken + _tokenAmount;

        emit RewardGiven(_address, _klayAmount, _tokenAmount);
    }

    function changeConfig(address _registryAddress, address _tokenAddress, bool _tokenLaunched) external override onlyOwner {
        registryAddress = _registryAddress;
        tokenAddress = _tokenAddress;
        tokenLaunched = _tokenLaunched;

        emit ConfigChanged(_registryAddress, _tokenAddress, _tokenLaunched);
    }
}