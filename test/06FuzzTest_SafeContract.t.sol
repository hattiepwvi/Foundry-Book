// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "forge-std/Test.sol";

contract Safe {
    receive() external payable {}

    function withdraw() public {
        payable(msg.sender).transfer(address(this).balance);
    }
}

contract SafeTest is Test {
    Safe safe;

    receive() external payable {}

    function setUp() public {
        safe = new Safe();
    }

    function test_Withdraw() public {
        payable(address(safe)).transfer(1 ether);
        uint256 preBalance = address(this).balance;
        safe.withdraw();
        uint256 postBalance = address(this).balance;
        assertEq(preBalance + 1 ether, postBalance);
    }

    // the largest amount for fuzz test is uint96
    function testFuzz_withdraw(uint96 amount) public {
        // vm.assume(amount > 0.1 ether)
        payable(address(safe)).transfer(amount);
        uint256 preBalance = address(this).balance;
        console.log(preBalance);
        safe.withdraw();
        uint256 postBalance = address(this).balance;
        assertEq(preBalance + amount, postBalance);
    }
}
