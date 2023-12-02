// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "forge-std/Test.sol";

contract TestContract is Test {
    string[] memory cmds = new string[](2);
    cmds[0] = "cat";
    cmds[1] = "address.text";
    byte32 memory results = vm.ffi(cmds);   
    address loadedAddress = abi.encode(results, (address)); 

}
