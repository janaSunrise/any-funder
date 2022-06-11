// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IWETH} from "../interfaces/IWETH.sol";

library CurrencyWrapper {
    function wrap(address wrappedCurrency, uint256 amount) internal {
        IWETH(wrappedCurrency).deposit{value: amount}();
    }

    function unwrap(address wrappedCurrency, uint256 amount) internal {
        IWETH(wrappedCurrency).withdraw(amount);
    }

    function wrapNativeAndTransfer(address wrappedCurrency, uint256 amount)
        internal
    {
        wrap(wrappedCurrency, amount);

        bool success = IWETH(wrappedCurrency).transfer(msg.sender, amount);
        require(success, "Unable to transfer WETH to user.");
    }

    function unwrapNativeAndTransfer(
        address wrappedCurrency,
        uint256 amount,
        address recipient
    ) internal {
        unwrap(wrappedCurrency, amount);

        bool success = IWETH(wrappedCurrency).transfer(recipient, amount);
        require(success, "Unable to transfer WETH to user.");
    }
}
