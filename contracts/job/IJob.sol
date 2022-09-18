// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IJob {
    event Executed();
    function execute() external;
    function executable() external view returns (bool);
}
