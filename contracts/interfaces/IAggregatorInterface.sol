// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAggregatorInterface {
    function decimals() external view returns (uint8);

    function latestAnswer() external view returns (int256);
}
