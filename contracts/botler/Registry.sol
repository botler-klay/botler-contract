// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../common/access/OwnableUpgradeable.sol";
import "../common/security/ReentrancyGuardUpgradeable.sol";
import "../job/IJob.sol";
import "./IReward.sol";

contract Registry is OwnableUpgradeable, ReentrancyGuardUpgradeable {

    struct RegistryStatus {
        uint256 minimumBotlerFee;
        uint256 registrationFee;
        uint256 executionFee;
        uint256 adminFee;
        uint256 accumulatedAdminFee;
        address tokenAddress;
        address rewardContract;
    }

    struct JobInfo {
        bool active;
        string name;
        string description;
        uint256 botlerFee;
        uint256 accumulatedFee;
        uint256 balance;
        uint32 callCount;
        address jobOwner;
    }

    RegistryStatus registryStatus;

    address[] public jobList;
    mapping(address => JobInfo) public jobInfo;
    mapping(address => bool) public botlerPermission;

    event JobRegistered(address indexed user, address indexed job);
    event JobActivated(address indexed job);
    event JobDeactivated(address indexed job);
    event BotlerGranted(address indexed user);
    event BotlerRevoked(address indexed user);
    event JobBalanceDeposited(address indexed job, address indexed depositer, uint256 amount);
    event JobBalanceWithdrawn(address indexed job, uint256 amount);
    event JobNameChanged(address indexed job, string name);
    event JobDescChanged(address indexed job, string desc);
    event JobBotlerFeeChanged(address indexed job, uint256 fee);
    event JobOwnerChanged(address indexed job, address indexed from, address indexed to);
    event AdminFeeWithdrawn(uint256 amount);

    function initialize(address _newOwner) external initializer {
        __Ownable_init();
        transferOwnership(_newOwner);
    }

    function registerJob(address _job, string memory _name, string memory _description, uint256 _botlerFee) external payable {
        require(_job != address(0));
        require(_botlerFee >= registryStatus.minimumBotlerFee);

        jobList.push(_job);

        JobInfo storage job = jobInfo[_job];
        job.active = true;
        job.name = _name;
        job.description = _description;
        job.botlerFee = _botlerFee;
        job.accumulatedFee = 0;
        job.balance = msg.value;
        job.callCount = 0;
        job.jobOwner = msg.sender;

        registryStatus.accumulatedAdminFee = registryStatus.accumulatedAdminFee + registryStatus.registrationFee;

        emit JobRegistered(msg.sender, _job);
    }

    function activateJob(address _job) external nonReentrant {
        JobInfo storage job = jobInfo[_job];
        require(job.jobOwner == msg.sender, 'ERR:NO_PERMISSION');
        job.active = true;
        emit JobActivated(_job);
    }

    function deactivateJob(address _job) external nonReentrant {
        JobInfo storage job = jobInfo[_job];
        require(job.jobOwner == msg.sender, 'ERR:NO_PERMISSION');
        job.active = false;
        emit JobDeactivated(_job);
    }

    function changeJobName(address _job, string memory _name) external nonReentrant {
        JobInfo storage job = jobInfo[_job];
        require(job.jobOwner == msg.sender, 'ERR:NO_PERMISSION');
        job.name = _name;
        emit JobNameChanged(_job, _name);
    }

    function changeJobDesc(address _job, string memory _desc) external nonReentrant {
        JobInfo storage job = jobInfo[_job];
        require(job.jobOwner == msg.sender, 'ERR:NO_PERMISSION');
        job.description = _desc;
        emit JobDescChanged(_job, _desc);
    }

    function changeJobBotlerFee(address _job, uint256 _fee) external nonReentrant {
        JobInfo storage job = jobInfo[_job];
        require(job.jobOwner == msg.sender, 'ERR:NO_PERMISSION');
        job.botlerFee = _fee;
        emit JobBotlerFeeChanged(_job, _fee);
    }

    function changeJobOwner(address _job, address _newOwner) external nonReentrant {
        JobInfo storage job = jobInfo[_job];
        require(job.jobOwner == msg.sender, 'ERR:NO_PERMISSION');
        job.jobOwner = _newOwner;
        emit JobOwnerChanged(_job, msg.sender, _newOwner);
    }

    function grantBotler(address _address) external nonReentrant onlyOwner {
        botlerPermission[_address] = true;
        emit BotlerGranted(_address);
    }

    function revokeBotler(address _address) external nonReentrant onlyOwner {
        botlerPermission[_address] = false;
        emit BotlerRevoked(_address);
    }

    function checkExecutable(address _job) external view returns (bool) {
        return IJob(_job).executable();
    }

    function execute(address _job) external nonReentrant {
        JobInfo storage job = jobInfo[_job];
        require(botlerPermission[msg.sender], 'ERR:NO_PERMISSION');
        uint256 klayLeft = gasleft();
        IJob(_job).execute();
        job.callCount = job.callCount + 1;
        job.accumulatedFee = job.accumulatedFee + job.botlerFee;
        uint256 usedKlay = klayLeft - gasleft();
        require(job.balance >= registryStatus.adminFee + usedKlay + job.botlerFee);
        IReward(registryStatus.rewardContract).giveReward(msg.sender, usedKlay + job.botlerFee, 0);
        registryStatus.accumulatedAdminFee = registryStatus.accumulatedAdminFee + registryStatus.adminFee;
        job.balance = job.balance - (registryStatus.adminFee + usedKlay + job.botlerFee);
    }

    function deposit(address _job) payable external nonReentrant {
        uint256 amount = msg.value;
        JobInfo storage job = jobInfo[_job];
        job.balance = job.balance + amount;
        emit JobBalanceDeposited(_job, msg.sender, amount);
    }

    function withdraw(address _job, uint256 _amount) external nonReentrant {
        require(address(this).balance >= _amount, 'ERR:NOT_ENOUGH_BALANCE');

        JobInfo storage job = jobInfo[_job];
        require(job.jobOwner == msg.sender, 'ERR:NO_PERMISSION');

        uint256 balance = job.balance;
        require(balance >= _amount, 'ERR:NOT_ENOUGH_BALANCE');

        job.balance = balance - _amount;
        payable(msg.sender).transfer(_amount);
        emit JobBalanceWithdrawn(_job, _amount);
    }

    function withdrawAdminFee() external onlyOwner nonReentrant {
        uint256 amount = registryStatus.accumulatedAdminFee;
        require(address(this).balance >= amount, 'ERR:NOT_ENOUGH_BALANCE');
        registryStatus.accumulatedAdminFee = 0;
        payable(msg.sender).transfer(amount);
        emit AdminFeeWithdrawn(amount);
    }
}