// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ERRORS
error StringGreaterThan64Bytes();

library EncodeStringToUint256Array {
    function encodeStringToUint256Array(string memory str) public pure returns (uint256[2] memory) {
        bytes memory b = bytes(str);
        if (b.length >= 64) revert StringGreaterThan64Bytes();

        uint256[2] memory result;

        for (uint256 i; i < b.length;) {
            if (i < 32) {
                // Pack the first 32 bytes into result[0]
                result[0] |= uint256(uint8(b[i])) << (8 * (31 - i));
            } else {
                // Pack the remaining bytes into result[1]
                result[1] |= uint256(uint8(b[i])) << (8 * (63 - i));
            }
            unchecked {
                ++i;
            }
        }

        return result;
    }
}
