// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "permit2/interfaces/ISignatureTransfer.sol";

interface ICodeWithPermit2 {
    event Permit2Transfer(
        address indexed asset,
        address indexed from,
        address indexed to,
        uint256 amount
    );

    event AssetTransferred(
        address indexed asset,
        address indexed from,
        address indexed to,
        uint256 amount
    );

    struct TransferParam {
        address asset;
        address receiver;
        uint256 amount;
    }

    function transferWithPermit2(
        TransferParam memory transferParam,
        ISignatureTransfer.PermitTransferFrom memory permit2Transfer,
        ISignatureTransfer.SignatureTransferDetails memory transferDetails,
        bytes memory sig
    ) external;
}
