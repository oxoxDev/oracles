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

import "../../BaseFeedLPPendle.sol";

/// @title LPUSDeDec262024Oracle
/// @author Zerolend.
/// @notice Gives the price of LP-USDe in ETH in base 8
contract LPUSDeDec262024Oracle is BaseFeedLPPendle {
    string public constant description = "LP-USDe/USD Oracle Dec 26 2024";

    /// @notice Constructor for an oracle following BaseFeedLPPendle
    /// @param _pendleLPUSDeMarket The address of the Pendle LP-USDe market
    /// @param _ethUsdFeed The address of the ETH/USD feed
    constructor(
        address _pendleLPUSDeMarket,
        address _ethUsdFeed
    )
        BaseFeedLPPendle(
            _pendleLPUSDeMarket,
            IPriceFeed(_ethUsdFeed),
            "Pendle LP-USDe/USD Oracle",
            1800 // 30-minute TWAP
        )
    {
        // nothing
    }
}
