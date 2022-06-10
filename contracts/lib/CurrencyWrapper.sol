// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IWETH} from "../interfaces/IWETH.sol";

library CurrencyWrapper {
    function wrapNativeAndTransfer(address wrappedCurrency, uint256 amount)
        internal
    {
        IWETH weth = IWETH(wrappedCurrency);

        weth.deposit{value: amount}();

        bool success = weth.transfer(msg.sender, amount);
        require(success, "Unable to transfer WETH to user.");
    }

    function unwrapNativeAndTransfer(
        address wrappedCurrency,
        uint256 amount,
        address recipient
    ) internal {
        IWETH weth = IWETH(wrappedCurrency);

        weth.withdraw(amount);

        bool success = weth.transfer(recipient, amount);
        require(success, "Unable to transfer WETH to user.");
    }
}
