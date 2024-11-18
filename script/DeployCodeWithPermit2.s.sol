// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/CodeWithPermit2.sol";

contract DeployCodeWithPermit2 is Script {
    address private kaia_permit2_address =
        0xAFF6678E8F6eAe7B36d70bffffb7046Ee32D5e81;

    function run() public returns (CodeWithPermit2, Permit2) {
        return deployCodeWithPermit2();
    }

    function deployCodeWithPermit2() public returns (CodeWithPermit2, Permit2) {
        Permit2 _permit2 = Permit2(kaia_permit2_address);

        vm.startBroadcast();
        CodeWithPermit2 codeWithPermit2 = new CodeWithPermit2(_permit2);
        vm.stopBroadcast();

        return (codeWithPermit2, _permit2);
    }
}
