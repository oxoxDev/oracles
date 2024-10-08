// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IApi3ProxyConsumer {
    function read() external view returns (int224 value, uint32 timestamp);
}
