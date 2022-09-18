// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IJob.sol";

// Simple CronJob
// It is not exactly same to 'cronjob'.
// However, it will be executed once a day.
contract SimpleCronJob is IJob {
    uint256 lastExecution = 0;
    event DoSomeThing(uint256 timestamp);

    function execute() override external {
        require(_executable());

        // Recommended: To protect the suspicious executions
        // require(msg.sender == JOB_REGISTRY_ADDRESS)

        lastExecution = block.timestamp;
        emit DoSomeThing(lastExecution);
        emit Executed();
    }

    function executable() external override view returns (bool) {
        return _executable();
    }

    function _executable() internal view returns (bool) {
        uint256 current = block.timestamp;
        if (current < lastExecution + (23 * 60 * 60)) {
            return false;
        }
        if ((current % (24 * 60 * 60)) < 3600) {
            return true;
        } else {
            return false;
        }
    }
}