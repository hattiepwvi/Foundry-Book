// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "forge-std/Test.sol";

contract TestContract is Test {
    function testMyFFI() public {
        string[] memory cmds = new string[](2);
        cmds[0] = "cat";
        cmds[1] = "address.text";
        bytes memory results = vm.ffi(cmds);
        address loadedAddress = abi.decode(results, (address));
    }
}
