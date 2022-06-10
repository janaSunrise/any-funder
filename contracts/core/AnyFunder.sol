// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

import "../lib/Constants.sol";

contract AnyFunder is Ownable {
    address payable private _owner;

    address private _currency;
    address private _wrappedToken;

    ISwapRouter private immutable _swapRouter;

    constructor(
        address currency,
        address wrappedToken,
        ISwapRouter swapRouter
    ) {
        _owner = payable(msg.sender);
        _currency = currency;
        _wrappedToken = wrappedToken;
        _swapRouter = swapRouter;
    }

    /// @dev Withdraw all funds from the contract.
    // TODO: Possibly add support for payment splitters?
    function withdrawFunds() public onlyOwner {
        if (_currency == Constants.NATIVE_TOKEN) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool success, ) = _owner.call{value: address(this).balance}("");
            require(success, "Unable to send value to owner.");
        } else {
            IERC20 token = IERC20(_currency);

            // Get the balance of this contract.
            uint256 balance = token.balanceOf(address(this));

            if (balance > 0) {
                TransferHelper.safeTransfer(_currency, _owner, balance);
            }
        }
    }
}
