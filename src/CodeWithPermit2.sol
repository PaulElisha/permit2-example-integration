// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/ICodeWithPermit2.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "permit2/Permit2.sol";
import "permit2/interfaces/ISignatureTransfer.sol";

contract CodeWithPermit2 is ICodeWithPermit2 {
    using SafeERC20 for IERC20;

    Permit2 private immutable permit2;

    constructor(Permit2 _permit2) {
        permit2 = _permit2;
    }

    function transferWithPermit2(
        TransferParam memory transferParam,
        ISignatureTransfer.PermitTransferFrom memory permit2Transfer,
        ISignatureTransfer.SignatureTransferDetails memory transferDetails,
        bytes memory sig
    ) public returns (bool) {
        if (transferParam.asset != permit2Transfer.permitted.token) {
            revert();
        }

        uint256 userBalance = IERC20(transferParam.asset).balanceOf(msg.sender);

        if (userBalance > 0) {
            if (
                transferDetails.to != address(this) ||
                transferDetails.requestedAmount > userBalance ||
                permit2Transfer.permitted.amount != transferDetails.amount
            ) {
                revert();
            }
        }

        uint256 contractBalance = IERC20(transferParam.asset).balanceOf(
            address(this)
        );

        permit2.permitTransferFrom(
            permit2Transfer,
            transferDetails,
            msg.sender,
            sig
        );

        if (contractBalance <= 0) {
            revert();
        }

        emit Permit2Transfer(
            transferParam.asset,
            msg.sender,
            address(this),
            transferDetails.requestedAmount
        );

        uint256 receiverBalanceBefore = IERC20(transferParam.asset).balanceOf(
            transferParam.receiver
        );

        transferParam.asset.safeTransfer(
            transferParam.receiver,
            transferParam.amount
        );

        uint256 receiverBalanceAfter = IERC20(transferParam.asset).balanceOf(
            transferParam.receiver
        );

        if (receiverBalanceAfter <= receiverBalanceBefore) {
            revert();
        }

        emit AssetTransferred(
            transferParam.asset,
            address(this),
            transferParam.receiver,
            transferDetails.requestedAmount
        );

        return true;
    }
}
