// SPDX-License-Identifier: GPL-3.0

// ███████╗███████╗██████╗  ██████╗
// ╚══███╔╝██╔════╝██╔══██╗██╔═══██╗
//   ███╔╝ █████╗  ██████╔╝██║   ██║
//  ███╔╝  ██╔══╝  ██╔══██╗██║   ██║
// ███████╗███████╗██║  ██║╚██████╔╝
// ╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝

// Website: https://zerolend.xyz
// Discord: https://discord.gg/zerolend
// Twitter: https://twitter.com/zerolendxyz

pragma solidity ^0.8.12;

import {IAggregatorInterface} from "../interfaces/IAggregatorInterface.sol";
import {BaseOracleLPPendle} from "./BaseOracleLPPendle.sol";

/// @title BaseFeedLPPendle
/// @author Zerolend
/// @notice Base Contract to implement the IAggregatorInterface for Pendle LP tokens
contract BaseFeedLPPendle is IAggregatorInterface, BaseOracleLPPendle {
    /// @notice The Chainlink aggregator for ASSET/USD
    IAggregatorInterface public assetUsdAggregator;

    /// @notice Constructor for an oracle following IAggregatorInterface
    /// @param _twapDuration The duration of the TWAP used to calculate the LP price
    /// @param _assetUsdAggregator The Chainlink aggregator for the underlying asset to USD
    /// @param _market The Pendle market address
    /// @param _requireOracleStateValidation Whether to validate oracle state
    constructor(
        uint32 _twapDuration,
        address _assetUsdAggregator,
        address _market,
        bool _requireOracleStateValidation
    )
        BaseOracleLPPendle(_twapDuration, _market, _requireOracleStateValidation)
    {
        assetUsdAggregator = IAggregatorInterface(_assetUsdAggregator);
    }

    /// @inheritdoc IAggregatorInterface
    function decimals() external pure override returns (uint8) {
        return 8;
    }

    function rawPrice() external view returns (uint256) {
        return _getQuoteAmount();
    }

    function usdPrice() external view returns (uint256) {
        return uint256(assetUsdAggregator.latestAnswer());
    }

    /// @inheritdoc IAggregatorInterface
    /// @dev This function gives the latest answer in 8 decimals.
    function latestAnswer() external view returns (int256) {
        uint256 lpRate = _getQuoteAmount();
        int256 assetToUsd = assetUsdAggregator.latestAnswer();
        
        // lpRate is in 18 decimals, assetToUsd is in 8 decimals
        // Result should be in 8 decimals
        return int256((lpRate * uint256(assetToUsd)) / BASE_18);
    }
} 