// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PriceOracle {
    uint256 public price;
    uint256 public updatedAt;

    function setPrice(uint256 _price) external {
        price = _price;
        updatedAt = block.timestamp;
    }
}
