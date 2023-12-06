// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "forge-std/Test.sol";

contract Safe {
    receive() external payable {}

    function withdraw() public {
        payable(msg.sender).transfer(address(this).balance);
    }
}
