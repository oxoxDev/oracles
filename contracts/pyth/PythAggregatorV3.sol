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

import {PythStructs} from "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";
import {IPyth} from "@pythnetwork/pyth-sdk-solidity/IPyth.sol";

/**
 * @title A port of a chainlink aggregator powered by pyth network feeds
 * @author Deadshot Ryker
 * @notice This does not store any roundId information on-chain. Please review the code before using this implementation.
 */
contract PythAggregatorV3 {
    bytes32 public priceId;
    IPyth public pyth;

    uint256 public constant HEART_BEAT = 1 days;

    constructor(address _pyth, bytes32 _priceId) {
        priceId = _priceId;
        pyth = IPyth(_pyth);
    }

    function updateFeeds(bytes[] calldata priceUpdateData) public payable {
        pyth.updatePriceFeeds{value: msg.value}(priceUpdateData);
    }

    function decimals() public view virtual returns (uint8) {
        PythStructs.Price memory price = pyth.getPriceNoOlderThan(priceId, HEART_BEAT);
        return uint8(-1 * int8(price.expo));
    }

    function description() public pure returns (string memory) {
        return "A port of a chainlink aggregator powered by pyth network feeds";
    }

    function version() public pure returns (uint256) {
        return 1;
    }

    function latestAnswer() public view virtual returns (int256) {
        PythStructs.Price memory price = pyth.getPriceNoOlderThan(priceId, HEART_BEAT);
        return int256(price.price);
    }

    function latestTimestamp() public view returns (uint256) {
        PythStructs.Price memory price = pyth.getPriceNoOlderThan(priceId, HEART_BEAT);
        return price.publishTime;
    }

    function latestRound() public view returns (uint256) {
        // use timestamp as the round id
        return latestTimestamp();
    }

    function getAnswer(uint256) public view returns (int256) {
        return latestAnswer();
    }

    function getTimestamp(uint256) external view returns (uint256) {
        return latestTimestamp();
    }

    function getRoundData(uint80 _roundId)
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        PythStructs.Price memory price = pyth.getPriceUnsafe(priceId);
        return (_roundId, int256(price.price), price.publishTime, price.publishTime, _roundId);
    }

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        PythStructs.Price memory price = pyth.getPriceUnsafe(priceId);
        roundId = uint80(price.publishTime);
        return (roundId, int256(price.price), price.publishTime, price.publishTime, roundId);
    }

    function getUpdateFee(bytes[] calldata priceUpdateData) public view returns (uint256) {
        return pyth.getUpdateFee(priceUpdateData);
    }
}
