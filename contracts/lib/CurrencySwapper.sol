// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

import "./Constants.sol";
import "./CurrencyWrapper.sol";

library CurrencySwapper {
    function swap(
        uint256 amount, // If the amount of tokenOut is known, determine this using `IQuoter` in uniswap.
        address tokenIn,
        address tokenOut,
        address recipient,
        ISwapRouter router,
        address wrappedToken
    ) internal returns (uint256) {
        bool tokenOutWrapped = tokenOut == Constants.NATIVE_TOKEN;

        // If the tokenIn is the same as the tokenOut, we can just transfer the amount directly.
        if (tokenIn == tokenOut) {
            TransferHelper.safeTransferFrom(
                tokenIn,
                msg.sender,
                recipient,
                amount
            );

            return amount;
        }

        // If the tokenIn is `NATIVE_TOKEN`, wrapping is required.
        if (tokenIn == Constants.NATIVE_TOKEN) {
            CurrencyWrapper.wrapNativeAndTransfer(wrappedToken, amount);
        }

        // If the tokenOut is native currency, make it wrapped token.
        // And, change the recipient to the current contract
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

        // If tokenOut is wrapped, unwrap and send to user.
        if (tokenOutWrapped && recipient != address(this)) {
            CurrencyWrapper.unwrapNativeAndTransfer(
                wrappedToken,
                amountOut,
                recipient
            );
        }

        return amountOut;
    }
}
