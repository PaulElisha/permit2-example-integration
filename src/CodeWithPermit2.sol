// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CodeWithPermit2 {
    Permit2 private immutable permit2;

    constructor(Permit2 _permit2) {
        permit2 = _permit2;
    }
}
