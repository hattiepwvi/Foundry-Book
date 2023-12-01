// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.21;

import "forge-std/Test.sol";

contract ExpectEmit {
  event Transfer(address indexed from, address indexed to, uint256 amount);

  function t() public {
    emit Transfer(msg.sender, address(1337), 1337);
  }
}

contract EmitContractTest is Test {
  event Transfer(address indexed from, address indexed to, uint256 amount);

  function test_ExpectEmit() public {
    ExpectEmit emitter = new ExpectEmit();
    vm.expectEmit(true, true, false, true);
    emit Transfer(address(this), address(1337), 1337);
    emitter.t();
  }

  function test_ExpectEmit_DoNotCheckData() public {
    ExpectEmit emitter = new ExpectEmit();
    vm.expectEmit(true, true, false, false);
    emit Transfer(address(this), address(1337), 1338);
    emitter.t();
  }
}
