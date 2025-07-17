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

// Interface for Chainlink price feeds (compatible with standard Chainlink feeds)
interface IPriceFeed {
    function decimals() external view returns (uint8);
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

/// @title BaseFeedLPPendle
/// @author Zerolend
/// @notice Chainlink-compatible price feed for Pendle LP tokens
/// @dev Converts LP/Asset rate to LP/USD using external asset price feed
/// @dev Supports both 8-decimal and 18-decimal Chainlink feeds
contract BaseFeedLPPendle is IAggregatorInterface, BaseOracleLPPendle {
    
    /// @notice Number of decimals in the price feed output (Chainlink standard)
    uint8 internal constant FEED_DECIMALS = 8;
    
    /// @notice The Chainlink price feed for asset pricing
    IPriceFeed public immutable FEED_ASSET;
    
    /// @notice Decimal conversion factor for asset price feed
    uint256 public immutable ASSET_PRICE_SCALE;

    error InvalidAssetFeed();

    /// @notice Constructor for LP oracle with Chainlink interface
    /// @param _pendleMarketAddress The address of the Pendle LP market
    /// @param _priceFeedAsset The Chainlink feed for underlying asset/USD pricing
    /// @param _oracleName Description of the oracle (e.g., "weETH LP/USD Oracle")
    /// @param _twapDuration The duration of the TWAP in seconds (e.g., 1800 for 30 minutes)
    constructor(
        address _pendleMarketAddress,
        IPriceFeed _priceFeedAsset,
        string memory _oracleName,
        uint32 _twapDuration
    )
        BaseOracleLPPendle(
            _pendleMarketAddress,
            _oracleName,
            _twapDuration
        )
    {
        FEED_ASSET = _priceFeedAsset;
        
        // Calculate scaling factor based on asset feed decimals
        uint8 assetDecimals = _priceFeedAsset.decimals();
        if (assetDecimals > 18) revert InvalidAssetFeed();
        
        ASSET_PRICE_SCALE = 10 ** (18 - assetDecimals);
    }

    /// @inheritdoc IAggregatorInterface
    function decimals() external pure override returns (uint8) {
        return FEED_DECIMALS;
    }

    /// @inheritdoc IAggregatorInterface
    /// @dev Returns the LP token price in USD with 8 decimals
    /// @dev Formula: LP_USD_Price = (LP_Asset_Rate * Asset_USD_Price) / 1e18
    function latestAnswer() external view returns (int256) {
        return _getLatestPrice();
    }

    /// @notice Internal function to calculate the latest LP price in USD
    /// @dev Core pricing logic combining LP/Asset rate with Asset/USD price
    function _getLatestPrice() internal view returns (int256) {
        // Get asset price from Chainlink feed
        (, int256 assetPriceRaw, , , ) = FEED_ASSET.latestRoundData();
        if (assetPriceRaw <= 0) revert InvalidAssetFeed();
        
        // Scale asset price to 18 decimals
        uint256 assetPrice = uint256(assetPriceRaw) * ASSET_PRICE_SCALE;
        
        // Get LP to asset rate from Pendle (already in 18 decimals)
        uint256 lpToAssetRate = _getLpToAssetRate();
        
        // Calculate LP/USD price: (LP/Asset) * (Asset/USD)
        uint256 lpPriceUsd = (lpToAssetRate * assetPrice) / PRECISION_FACTOR_E18;
        
        // Convert to 8 decimals for Chainlink compatibility
        return int256(lpPriceUsd / 1e10);
    }

    /// @notice Get the current underlying asset price in USD
    /// @dev Returns price in original feed decimals
    function getAssetPrice() external view returns (uint256) {
        (, int256 price, , , ) = FEED_ASSET.latestRoundData();
        return uint256(price);
    }

    /// @notice Get the current underlying asset price scaled to 18 decimals
    function getAssetPriceScaled() external view returns (uint256) {
        (, int256 price, , , ) = FEED_ASSET.latestRoundData();
        return uint256(price) * ASSET_PRICE_SCALE;
    }

    /// @notice Calculate LP value for a given amount
    /// @param lpAmount Amount of LP tokens (in LP token decimals)
    /// @return valueUsd Value in USD (8 decimals)
    function calculateLpValue(uint256 lpAmount) external view returns (uint256) {
        int256 pricePerLp = _getLatestPrice();
        return (lpAmount * uint256(pricePerLp)) / PRECISION_FACTOR_E18;
    }

    /// @notice Get detailed pricing information
    /// @return lpToAssetRate LP to asset rate (18 decimals)
    /// @return lpToSyRate LP to SY rate (18 decimals) 
    /// @return assetPriceUsd Asset price in USD (original feed decimals)
    /// @return lpPriceUsd LP price in USD (8 decimals)
    function getPricingDetails() external view returns (
        uint256 lpToAssetRate,
        uint256 lpToSyRate,
        uint256 assetPriceUsd,
        uint256 lpPriceUsd
    ) {
        lpToAssetRate = _getLpToAssetRate();
        lpToSyRate = _getLpToSyRate();
        (, int256 price, , , ) = FEED_ASSET.latestRoundData();
        assetPriceUsd = uint256(price);
        lpPriceUsd = uint256(_getLatestPrice());
    }

    /// @notice Full Chainlink aggregator interface compatibility
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        // Get timestamp from asset feed for consistency
        (, , startedAt, updatedAt, ) = FEED_ASSET.latestRoundData();
        
        return (
            1, // Simple round ID
            _getLatestPrice(),
            startedAt,
            updatedAt,
            1
        );
    }
} 