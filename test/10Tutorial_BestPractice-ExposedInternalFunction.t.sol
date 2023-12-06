// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "forge-std/Test.sol";
import {MyContract} from "src/10Tutorial-BestPractices-ExposedInternalFunction.sol";

contract MyContractHarness is MyContract {
    function exposed_myInternalMethod() external returns (uint) {
        return myInternalMethod();
    }
}

// This is my design as shown below (not official version)
contract MyContractTest is Test {
    MyContractHarness public myContractHarness;

    function setUp() public {
        myContractHarness = new MyContractHarness();
    }

    function testMyContract() public returns (uint) {
        return myContractHarness.exposed_myInternalMethod();
    }
}
