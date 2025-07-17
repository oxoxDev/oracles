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

import {IPMarket} from "@pendle/core-v2/contracts/interfaces/IPMarket.sol";
import {PendleLpOracleLib} from "@pendle/core-v2/contracts/oracles/PendleLpOracleLib.sol";

/// @title BaseOracleLPPendle
/// @author Zerolend
/// @notice Base oracle implementation for LP tokens on Pendle
/// @dev LP oracle represents a user's share in Pendle AMM which pairs up PT and SY
/// @dev Uses PendleLpOracleLib which internally uses PT oracle data for hypothetical trade simulation
abstract contract BaseOracleLPPendle {
    
    /// @notice Precision factor for computations (18 decimals)
    uint256 internal constant PRECISION_FACTOR_E18 = 1e18;
    
    /// @notice The Pendle market interface
    IPMarket public immutable PENDLE_MARKET;
    
    /// @notice TWAP duration in seconds
    uint32 public immutable TWAP_DURATION;
    
    /// @notice Name/description of the oracle
    string public name;

    constructor(
        address _pendleMarketAddress,
        string memory _oracleName,
        uint32 _twapDuration
    ) {
        PENDLE_MARKET = IPMarket(_pendleMarketAddress);
        name = _oracleName;
        TWAP_DURATION = _twapDuration;
    }

    /// @notice Get the LP to asset rate using Pendle's LP oracle library
    /// @dev This function simulates hypothetical AMM trades using PT oracle TWAP data
    /// @dev The LP oracle inherently uses PT oracle through PendleLpOracleLib internal calls
    /// @dev Includes built-in insolvency protection for both LP and underlying assets
    /// @return LP to asset rate in 18 decimals
    function _getLpToAssetRate() internal view returns (uint256) {
        return PendleLpOracleLib.getLpToAssetRate(
            PENDLE_MARKET,
            TWAP_DURATION
        );
    }

    /// @notice Get the LP to SY rate instead of LP to asset rate
    /// @dev Alternative pricing method for different use cases
    /// @dev SY (Standardized Yield) is the interest-bearing token wrapper
    /// @return LP to SY rate in 18 decimals  
    function _getLpToSyRate() internal view returns (uint256) {
        return PendleLpOracleLib.getLpToSyRate(
            PENDLE_MARKET,
            TWAP_DURATION
        );
    }

    /// @notice Get raw LP price in asset terms without USD conversion
    /// @dev External function for accessing LP/Asset rate
    function rawPrice() external view returns (uint256) {
        return _getLpToAssetRate();
    }

    /// @notice Get LP to SY rate for external access
    /// @dev Useful when working with SY tokens directly
    function lpToSyRate() external view returns (uint256) {
        return _getLpToSyRate();
    }

    /// @notice Check if the market has expired
    /// @dev After expiry, pricing calculations change (PT = Asset)
    function isExpired() public view returns (bool) {
        return block.timestamp >= PENDLE_MARKET.expiry();
    }

    /// @notice Get market expiry timestamp
    function getMaturity() public view returns (uint256) {
        return PENDLE_MARKET.expiry();
    }
} 