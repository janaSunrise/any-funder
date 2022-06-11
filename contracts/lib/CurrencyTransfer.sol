// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./Constants.sol";

library CurrencyTransfer {
    using SafeERC20 for IERC20;

    function transferNativeToken(address to, uint256 amount) internal {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = to.call{value: amount}("");
        require(success, "Unable to send value to user.");
    }

    function transferERC20(
        address currency,
        address from,
        address to,
        uint256 amount
    ) internal {
        if (from == to) {
            return;
        }

        IERC20 token = IERC20(currency);

        // Invoke `safeTransfer` if the contract is sending funds, else `safeTransferFrom`.
        if (from == address(this)) {
            token.safeTransfer(to, amount);
        } else {
            token.safeTransferFrom(from, to, amount);
        }
    }
}
