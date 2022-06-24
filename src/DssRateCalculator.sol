// SPDX-License-Identifier: BSD-4-Clause
pragma solidity ^0.8.15;

import "./ABDKMath64x64.sol";

contract DssRateCalculator {

    using ABDKMath64x64 for *;

    uint256 constant internal BPS_ONE_PCT             = 100;
    uint256 constant internal BPS_ONE_HUNDRED_PCT     = 100 * BPS_ONE_PCT;
    uint256 constant internal ANNUAL_SECONDS          = 60*60*24*365;
    uint128 constant internal DENOMINATOR             = 2**64;

    function getRate(uint256 rate_bps) external pure returns (uint256 rate) {
        require(rate_bps < BPS_ONE_HUNDRED_PCT);
        uint128 normalized_rate = uint128(10000 + uint128(rate_bps));
        uint128 numerator64x64  = uint128(normalized_rate * DENOMINATOR / 10000);
        int128  lograte64x64    = ABDKMath64x64.ln(int128(numerator64x64));
        int128  blockrate64x64  = ABDKMath64x64.div(lograte64x64, ABDKMath64x64.fromUInt(ANNUAL_SECONDS));
        rate = uint256(int256(ABDKMath64x64.mul(ABDKMath64x64.exp(blockrate64x64), 1e27)));
    }
}
