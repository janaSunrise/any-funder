// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

import "../lib/Constants.sol";
import "../lib/CurrencySwapper.sol";
import "../lib/CurrencyTransfer.sol";

contract AnyFunder is Ownable {
    address payable private _owner;

    address private _currency;
    address private _wrappedToken;

    ISwapRouter private immutable _swapRouter;

    // Counter for payments done.
    uint256 private _paymentCounter;

    struct Payment {
        address from;
        string message;
        uint256 amount;
    }

    // Maintain a history of payments, paymentIndex => payment.
    mapping(uint256 => Payment) private _payments;

    // Events to be emitted.
    event PaymentMade(Payment payment);

    constructor(
        address currency_,
        address wrappedToken,
        ISwapRouter swapRouter
    ) {
        _owner = payable(msg.sender);
        _currency = currency_;
        _wrappedToken = wrappedToken;
        _swapRouter = swapRouter;
    }

    // Getter functions
    function currency() public view returns (address) {
        return _currency;
    }

    function paymentsHistory() public view returns (Payment[] memory) {
        Payment[] memory payments = new Payment[](_paymentCounter);

        for (uint256 i = 0; i < _paymentCounter; i++) {
            payments[i] = _payments[i];
        }

        return payments;
    }

    /// @dev Pay a custom amount of specific currency.
    function payCustom(
        address userCurrency,
        uint256 amount,
        string memory message // Optional message to be displayed in the history.
    ) public payable {
        if (userCurrency == Constants.NATIVE_TOKEN) {
            require(msg.value == amount, "Amount must match the value sent.");
        }

        // Swap currency and move them to the contract.
        CurrencySwapper.swap(
            amount,
            userCurrency,
            _currency,
            address(this),
            _swapRouter,
            _wrappedToken
        );

        // Add the payment to the history
        _payments[_paymentCounter] = Payment(msg.sender, message, amount);

        // Emit the event.
        emit PaymentMade(_payments[_paymentCounter]);

        unchecked {
            _paymentCounter += 1;
        }
    }

    /// @dev Withdraw all funds from the contract.
    // TODO: Possibly add support for payment splitters?
    function withdrawFunds() public onlyOwner {
        if (_currency == Constants.NATIVE_TOKEN) {
            CurrencyTransfer.transferNativeToken(_owner, address(this).balance);
        } else {
            uint256 balance = IERC20(_currency).balanceOf(address(this));

            if (balance > 0) {
                CurrencyTransfer.transferERC20(
                    _currency,
                    address(this),
                    _owner,
                    balance
                );
            }
        }
    }

    // Override `transferOwnership` to change the `_owner` in this contract.
    // This can be called when deployed separately, or only through the registry (if used).
    function transferOwnership(address newOwner) public override onlyOwner {
        _owner = payable(newOwner);
        super.transferOwnership(newOwner);
    }
}
