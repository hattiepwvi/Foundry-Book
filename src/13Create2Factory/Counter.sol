// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/console.sol";

contract Counter {
    uint256 public count;

    function get() public view returns (uint256) {
        return count;
    }

    function inc() external {
        console.log("HERE", count);
        count += 1;
    }

    function dec() external {
        count -= 1;
    }
}
