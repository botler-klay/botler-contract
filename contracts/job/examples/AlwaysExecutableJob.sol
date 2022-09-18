// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IJob.sol";

// Always Executable Job
contract AlwaysExecutableJob is IJob {
    event DoSomeThing(uint256);

    function execute() override external {
        require(_executable());

        // Recommended: To protect the suspicious executions
        // require(msg.sender == JOB_REGISTRY_ADDRESS)

        emit DoSomeThing(0);
        emit Executed();
    }

    function executable() external override view returns (bool) {
        return _executable();
    }

    function _executable() internal view returns (bool) {
        return true;
    }
}