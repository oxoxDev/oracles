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

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IStandardizedYield, IPMarket} from "@pendle/core-v2/contracts/interfaces/IPMarket.sol";
import {PendleLpOracleLib} from "@pendle/core-v2/contracts/oracles/PendleLpOracleLib.sol";

/// @title BaseOracleLPPendle
/// @author Zerolend
/// @notice Base oracle implementation for LP tokens on Pendle
abstract contract BaseOracleLPPendle {
    uint256 public constant BASE_18 = 1 ether;
    uint256 public constant UNIT = 1e18;

    /// @notice The duration of the TWAP used to calculate the LP price
    uint32 public immutable twapDuration;

    IERC20 public immutable asset;
    IStandardizedYield public immutable sy;
    IPMarket public immutable market;
    uint256 public immutable maturity;

    // Oracle state validation
    bool public immutable requireOracleStateValidation;

    error TwapDurationTooLow();
    error CardinalityNotSatisfied();
    error OldestObservationNotSatisfied();

    constructor(
        uint32 _twapDuration,
        address _market,
        bool _requireOracleStateValidation
    ) {
        if (_twapDuration < 15 minutes) revert TwapDurationTooLow();
        twapDuration = _twapDuration;
        requireOracleStateValidation = _requireOracleStateValidation;

        // read the market
        market = IPMarket(_market);
        (sy, , ) = market.readTokens();
        asset = IERC20(sy.yieldToken());
        maturity = market.expiry();
    }

    /// @notice Get the LP token price in asset terms
    function _getQuoteAmount() internal view virtual returns (uint256 quote) {
        // Optional oracle state validation 
        if (requireOracleStateValidation) {
            _validateOracleState();
        }

        uint256 lpRate = PendleLpOracleLib.getLpToAssetRate(
            market,
            twapDuration
        );

        quote = lpRate;
    }

    /// @notice Validate oracle state (cardinality and observation requirements)
    /// @dev Override in implementations that have access to PT oracle for validation
    function _validateOracleState() internal view virtual {
        // Base implementation - can be overridden in child contracts
        // For basic usage, we skip validation unless specifically implemented
    }

    /// @notice Get LP to asset rate directly from Pendle
    function _getLpToAssetRate() internal view returns (uint256) {
        return PendleLpOracleLib.getLpToAssetRate(market, twapDuration);
    }

    /// @notice Check if oracle state validation is required
    function getRequireOracleStateValidation() external view returns (bool) {
        return requireOracleStateValidation;
    }
} 