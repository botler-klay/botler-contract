// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IJob.sol";

contract Job is IJob {
    function execute() override external {
        // Recommended: To protect the suspicious executions.
        // require(msg.sender == JOB_REGISTRY_ADDRESS)
        require(_executable());
        // TODO: Not Implemented.
        emit Executed();
    }

    function executable() external override view returns (bool) {
        return _executable();
    }

    function _executable() internal view returns (bool) {
        // TODO: Not Implemented.
        return true;
    }
}