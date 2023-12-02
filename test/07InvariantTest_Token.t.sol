// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "forge-std/Test.sol";

interface IERC20Like {
    function balanceOf(address owner_) external view returns (uint256 balance_);

    function transferFrom(
        address owner_,
        address recipient_,
        uint256 amount_
    ) external returns (bool success_);
}

contract Basic4626Deposit {
    address public immutable asset;
    string public name;
    string public symbol;
    uint8 public immutable decimals;

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    constructor(
        address asset_,
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) public {
        asset = asset_;
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
    }

    function deposit(
        uint256 assets_,
        address receiver_
    ) external returns (uint256 shares_) {
        shares_ = convertToShares(assets_);

        require(receiver_ != address(0), "ZERO_RECEIVER");
        require(shares_ != uint256(0), "ZERO_SHARES");
        require(assets_ != uint256(0), "ZERO_ASSET");

        totalSupply += shares_;

        unchecked {
            balanceOf[msg.receiver_] += shares_;
        }

        IERC20Like(asset).transferFrom(msg.sender, address(this), assets_);
    }

    function transfer(
        address recipient_,
        uint256 amount_
    ) external returns (bool success_) {
        balanceOf[msg.sender] -= amount_;

        unchecked {
            balanceOf[recipient_] += amount_;
        }

        return true;
    }

    function convertToShares(
        uint256 assets_
    ) public view returns (uint256 shares_) {
        uint256 supply_ = totalSupply;
        shares_ = supply_ == 0 ? assets_ : (assets_ * supply_) / totalAssets();
    }

    function totalAssets() public view returns (uint assets_) {
        assets_ = IERC20Like(asset).balanceOf(address(this));
    }
}
