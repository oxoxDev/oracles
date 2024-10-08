// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IAggregatorInterface.sol";
import "./interfaces/IApi3ProxyConsumer.sol";

contract Api3AggregatorETH {
    IAggregatorInterface public immutable ethConsumer;
    IApi3ProxyConsumer public api3Proxy;
    error InvalidOraclePrice();

    constructor(address _marketApiProxy, address _ethUsdConsumer) {
        ethConsumer = IAggregatorInterface(_ethUsdConsumer);
        api3Proxy = IApi3ProxyConsumer(_marketApiProxy);
    }

    function latestAnswer() external view returns (int256 uniEthToUsdPrice) {
        int256 ethToUsd = ethConsumer.latestAnswer();
        if (ethToUsd < 0) revert InvalidOraclePrice();
        (int224 value, ) = api3Proxy.read();
        uniEthToUsdPrice = (ethToUsd * int256(value)) / 1e18;
    }
}
