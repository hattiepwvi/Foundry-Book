// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Create2 {
    error Create2InsufficientBalance(uint256 received, uint256 minimumNeeded);

    error Create2EmptyBytecode();

    error Create2FailedDeployment();

    function deploy(
        uint256 amount,
        bytes32 salt,
        bytes memory creationCode
    ) external payable returns (address addr) {
        if (msg.value < amount) {
            revert Create2InsufficientBalance(msg.value, amount);
        }

        if (creationCode.length == 0) {
            revert Create2EmptyBytecode();
        }

        /** callvalue: a lower level version of msg.value
         *   add: skips 32 bytes (0x20 in hex) to point to the actual creationCode
         *       - The bytes type in Solidity is a dynamically sized byte array, where the first 32 bytes of memory represent the length of the array, and the remaining bytes represent the actual data.
         *   mload(creationCode): the offset and length of the creationCode in memory
         */
        // assembly {
        //     addr := create2(
        //         callvalue(),
        //         add(creationCode, 0x20),
        //         mload(creationCode),
        //         salt
        //     )
        // }

        assembly {
            addr := create2(
                amount,
                add(creationCode, 0x20),
                mload(creationCode),
                salt
            )
        }

        if (addr == address(0)) {
            revert Create2FailedDeployment();
        }
    }

    function computeAddress(
        bytes32 salt,
        bytes memory creationCodeHash
    ) external view returns (address addr) {
        /** recreating the same formula, albeit without calling the CREATE2 opcode( keccak256(0xff ++ address ++ salt ++ keccak256(bytecode))[12:]  )
         * 0xff is a hardcoded prefix that prevents hash-collision between addresses that are deployed using CREATE and CREATE2.
         * The address param refers to the address of the contract that is calling the CREATE2 opcode, in our case the factory contract.
         * These 4 params are concatenated together, and keccak256 is used to generate a 32 byte hash. The first 12 bytes are truncated, and the remaining 20 bytes are used as the address of the deployed contract. */

        address contractAddress = address(this);

        /**
         * 1) mload(0x40) loads the free memory pointer into memory. This is the pointer that points to the next free memory slot in the memory array.
         * 2) mstore(add(ptr, 0x40), bytecodeHash) stores the bytecodeHash starting at the memory location pointed to by ptr + 0x40, i.e. ptr+ 64 bytes.
         * 3) mstore(add(ptr, 0x20), salt) stores the salt at the memory location pointed to by ptr + 0x20.
         * 4) mstore(ptr, contractAddress) stores the contractAddress at the memory location pointed to by ptr.
         * 5)let start := add(ptr, 0x0b) creates a new variable start that points to the memory location ptr + 0x0b, i.e. ptr + 11 bytes.
         * 6) Lastly, the mstore8 opcode can be used to store a single byte at a memory location. Here, we are storing the value 0xff at the memory location pointed to by start, which occupies the 12th byte of the memory slot.
         * 7) With all the values packed into their correct memory locations, we can now call keccak256 on the memory slot starting at start, and pass in the length of the memory slot as the second parameter. This will return a 32 byte hash, which we can truncate to get the final address.
         */

        assembly {
            let ptr := mload(0x40)

            mstore(add(ptr, 0x40), creationCodeHash)
            mstore(add(ptr, 0x20), salt)
            mstore(ptr, contractAddress)
            let start := add(ptr, 0x0b)
            mstore8(start, 0xff)
            addr := keccak256(start, 85)
        }
    }
}
