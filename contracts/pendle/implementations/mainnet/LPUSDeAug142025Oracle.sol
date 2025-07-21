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

/// @title LPUSDeAug142025Oracle
/// @author Zerolend.
/// @notice Gives the price of LP-USDe in ETH in base 8
contract LPUSDeAug142025Oracle is BaseFeedLPPendle {
    string public constant description = "LP-USDe/USD Oracle Aug 14 2025";
    address public constant USDE_PRICE_FEED = 0xa569d910839Ae8865Da8F8e70FfFb0cBA869F961;
    address public constant PENDLE_LP_USDE_MARKET = 0xE93B4A93e80BD3065B290394264af5d82422ee70;

    /// @notice Constructor for an oracle following BaseFeedLPPendle
    constructor()
        BaseFeedLPPendle(
            PENDLE_LP_USDE_MARKET,
            IPriceFeed(USDE_PRICE_FEED),
            "Pendle LP-USDe/USD Oracle",
            1800 // 30-minute TWAP
        )
    {
        // nothing
    }
}
