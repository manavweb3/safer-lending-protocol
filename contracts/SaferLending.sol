// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MockERC20.sol";
import "./PriceOracle.sol";

contract SaferLending {
    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    uint256 public constant LTV = 60; // 60%
    uint256 public constant LIQUIDATION_THRESHOLD = 70; // 70%
    uint256 public constant LIQUIDATION_DELAY = 10 minutes;
    uint256 public constant ORACLE_STALE_TIME = 5 minutes;

    /*//////////////////////////////////////////////////////////////
                                STATE
    //////////////////////////////////////////////////////////////*/

    MockERC20 public collateralToken;
    MockERC20 public debtToken;
    PriceOracle public priceOracle;

    struct Position {
        uint256 collateral;
        uint256 debt;
        uint256 lastUnhealthyTime;
    }

    mapping(address => Position) public positions;
}
