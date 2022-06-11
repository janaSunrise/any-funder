// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

import "./Constants.sol";
import "./CurrencyWrapper.sol";
import "./CurrencyTransfer.sol";

library CurrencySwapper {
    function swap(
        uint256 amount, // If the amount of tokenOut is known, determine this using `IQuoter` in uniswap.
        address tokenIn,
        address tokenOut,
        address recipient,
        ISwapRouter router,
        address wrappedToken
    ) internal returns (uint256) {
        bool isTokenInNative = tokenIn == Constants.NATIVE_TOKEN;

        // If the `tokenIn` is the same as the `tokenOut`, we can just transfer the amount directly.
        if (tokenIn == tokenOut) {
            if (isTokenInNative) {
                CurrencyTransfer.transferNativeToken(recipient, amount);
            } else {
                CurrencyTransfer.transferERC20(
                    tokenIn,
                    msg.sender,
                    recipient,
                    amount
                );
            }

            return amount;
        }

        // The `tokenOut` is set to wrapped if `NATIVE_TOKEN` is passed in.
        bool tokenOutWrapped = tokenOut == Constants.NATIVE_TOKEN;
        address actualRecipient = recipient; // Keep track of actual recipient to send the unwrapped native.

        // If the `tokenIn` is `NATIVE_TOKEN`, wrapping is required.
        if (isTokenInNative) {
            CurrencyWrapper.wrapNativeAndTransfer(wrappedToken, amount);
        }

        // Wrap `tokenOut` aswell if it's `NATIVE_TOKEN`.
        // And change the recipient to the current contract in order to unwrap.
        // If it's set as WETH by the user already, the contract doesn't need to unwrap and transfer
        if (tokenOutWrapped) {
            tokenOut = wrappedToken;
            recipient = address(this);
        }

        // Transfer funds from the user to the contract, then approve router.
        // Approval from user required to safely use the `safeTransferFrom`.
        // The allowance creation can be automated by loading token contract and making user sign the
        // transaction for it in the frontend.
        TransferHelper.safeTransferFrom(
            tokenIn,
            msg.sender,
            address(this),
            amount
        );
        TransferHelper.safeApprove(tokenIn, address(router), amount);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: Constants.POOL_FEE,
                recipient: recipient,
                deadline: block.timestamp, // solhint-disable-line
                amountIn: amount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        uint256 amountOut = router.exactInputSingle(params);

        // If `tokenOutWrapped` is true, unwrap and send to actual recipient before modifying
        // the `recipient` to the contract.
        if (tokenOutWrapped && recipient != address(this)) {
            CurrencyWrapper.unwrapNativeAndTransfer(
                wrappedToken,
                amountOut,
                actualRecipient
            );
        }

        return amountOut;
    }
}
