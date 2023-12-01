// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "forge-std/Test.sol";

interface IERC20Like {
    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract ViViToken {
    IERC20Like public token;
    address public owner;
    address public receiver;
    mapping(address => uint256) public balances;

    error InsufficientBalance();

    receive() external payable {}

    function deposit(uint256 amount) external {
        balances[msg.sender] += amount;
        token.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) external {
        if (token.balanceOf(address(this)) >= amount) {
            balances[msg.sender] -= amount;
            token.transferFrom(address(this), msg.sender, amount);
        } else {
            revert InsufficientBalance();
        }
    }

    function getBalance() external {
        return balances[msg.sender];
    }
}

contract TokenInvariantTest is Test {
    ViViToken viviToken;
    address owner;

    receive() external payable {}

    function setUp() public {
        viviToken = new ViViToken();
        owner = msg.sender;
    }

    function invariant_Deposit(uint256 amount) public {
        viviToken.deposit(amount);
        uint256 postDeposit = viviToken.balances[msg.sender];
        assertEq(postDeposit, amount);
    }

    function invaraint_Withdraw(uint256 amount) public {
        uint256 preWithdraw = viviToken.balances[msg.sender];
        viviToken.withdraw(amount);
        uint256 postWithdraw = viviToken.balances[msg.sender];
        assertEq(preWithdraw - amount, viviToken.balances[msg.sender]);
    }
}
