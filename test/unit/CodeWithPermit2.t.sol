// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/CodeWithPermit2.sol";
import "../../script/DeployCodeWithPermit2.s.sol";
import "../../src/Interfaces/ICodeWithPermit2.sol";
import "permit2/Permit2.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "../Helper/TestHelper.sol";
import "permit2/interfaces/IPermit2.sol";
import "permit2/interfaces/ISignatureTransfer.sol";
import "../mocks/MockERC20.sol";

contract CodeWithPermit2Test is Test, Constants, TestHelper {
    DeployCodeWithPermit2 deployCodeWithPermit2;
    CodeWithPermit2 codeWithPermit2;
    ICodeWithPermit2.TransferParam transferParam;
    IERC20 kaia;
    MockERC20 mockERC20;
    Permit2 permit2;

    address userA;
    address userB;

    uint256 privateKey;
    bytes32 domain_separator;
    bytes sig;

    uint256 internal mainnetFork;

    function setUp() public {
        mockERC20 = new MockERC20();
        permit2 = new Permit2();
        codeWithPermit2 = new CodeWithPermit2(permit2);

        // deployAssetScooper = new DeployAssetScooper();
        // (codeWithPermit2, permit2) = deployAssetScooper.run();

        privateKey = vm.envUint("PRIVATE_KEY");
        userA = vm.addr(privateKey);

        userB = makeAddr("USERB");

        console2.log(userA);

        vm.startPrank(userA);

        mockERC20.mint(userA, 100 ether);

        uint256 userABalance = mockERC20.balanceOf(userA);
        assertEq(
            userABalance,
            100 ether,
            "User A should have 100 ether after minting"
        );

        mockERC20.approve(address(permit2), type(uint256).max);

        vm.stopPrank();

        // aero = IERC20(AERO);

        // mainnetFork = vm.createFork(fork_url);
        // vm.selectFork(mainnetFork);
    }

    // function testMint() public {
    //     userA = makeAddr("userA");
    //     userB = makeAddr("userB");
    //     console2.log(userA);

    //     vm.startPrank(userA);

    //     mockERC20.mint(userA, 100 ether);

    //     uint256 balance = mockERC20.balanceOf(userA);
    //     assertEq(
    //         balance,
    //         100 ether,
    //         "User A should have 100 ether after minting"
    //     );

    //     vm.stopPrank();
    // }

    function testTransferWithPermit2() public {
        uint256 nonce = 0;
        domain_separator = permit2.DOMAIN_SEPARATOR();

        vm.startPrank(userA);
        mockERC20.approve(address(permit2), mockERC20.balanceOf(userA));
        vm.stopPrank();

        transferParam = createTransferParam(mockERC20, userB, amount);

        ISignatureTransfer.PermitTransferFrom
            memory permit2_ = defaultERC20PermitTransfer(
                address(mockERC20),
                nonce,
                mockERC20.balanceOf(userA)
            );

        sig = getPermitTransferSignature(
            permit2_,
            privateKey,
            address(codeWithPermit2),
            domain_separator
        );

        ISignatureTransfer.SignatureTransferDetails
            memory transferDetails_ = getTransferDetails(
                address(codeWithPermit2),
                mockERC20.balanceOf(userA)
            );

        vm.startPrank(userA);
        codeWithPermit2.transferWithPermit2(
            transferParam,
            permit2_,
            transferDetails_,
            sig
        );
        vm.stopPrank();
    }
}
