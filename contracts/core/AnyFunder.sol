// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

import "../lib/Constants.sol";
import "../lib/CurrencySwapper.sol";
import "../lib/CurrencyTransfer.sol";

contract AnyFunder is Ownable {
    address private _owner;
    address payable private _paymentReceiver;

    address private _currency; // The currency payment receiver receives the payment in.
    address private _wrappedToken; // The wrapped token for the specific chain. Eg, WETH for ETH.

    ISwapRouter private immutable _swapRouter;

    // Counter for payments done.
    uint256 private _paymentCounter;

    struct Payment {
        address from;
        string message;
        uint256 amount;
        uint256 timestamp;
    }

    // Maintain a history of payments, paymentIndex => payment.
    mapping(uint256 => Payment) private _payments;

    // Events to be emitted.
    event PaymentDone(Payment payment);

    constructor(
        address paymentReceiver,
        address currency_,
        address wrappedToken,
        ISwapRouter swapRouter
    ) {
        // Payment receiver receives the payment.
        // Can be an address, payment splitter or any kind of contract.
        if (paymentReceiver == address(0)) {
            _paymentReceiver = payable(msg.sender);
        } else {
            _paymentReceiver = payable(paymentReceiver);
        }

        // Owner is used for permissions.
        // Ensuring some of the functions are limited to the contract owner (who deployed the contract).
        _owner = msg.sender;

        _currency = currency_;
        _wrappedToken = wrappedToken;
        _swapRouter = swapRouter;
    }

    function currency() public view returns (address) {
        return _currency;
    }

    function paymentsHistory() public view returns (Payment[] memory) {
        Payment[] memory payments = new Payment[](_paymentCounter);

        for (uint256 i = 0; i < _paymentCounter; ) {
            payments[i] = _payments[i];

            unchecked {
                i++;
            }
        }

        return payments;
    }

    function totalPaymentReceived() public view returns (uint256) {
        uint256 total = 0;

        for (uint256 i = 0; i < _paymentCounter; ) {
            total += _payments[i].amount;

            unchecked {
                i++;
            }
        }

        return total;
    }

    /// @dev Pay a custom amount of specific currency
    function pay(
        address userCurrency,
        uint256 amount,
        string memory message // Optional message to be displayed in the history
    ) public payable {
        if (userCurrency == Constants.NATIVE_TOKEN) {
            require(
                msg.value == amount,
                "AnyFunder: Amount must match msg.value"
            );
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

        _payments[_paymentCounter] = Payment(
            msg.sender,
            message,
            amount,
            block.timestamp
        );

        emit PaymentDone(_payments[_paymentCounter]);

        unchecked {
            _paymentCounter += 1;
        }
    }

    /// @dev Withdraw all funds from the contract.
    function withdrawFunds() public onlyOwner {
        if (_currency == Constants.NATIVE_TOKEN) {
            CurrencyTransfer.transferNativeToken(
                _paymentReceiver,
                address(this).balance
            );
        } else {
            uint256 balance = IERC20(_currency).balanceOf(address(this));

            if (balance > 0) {
                CurrencyTransfer.transferERC20(
                    _currency,
                    address(this),
                    _paymentReceiver,
                    balance
                );
            }
        }
    }

    // Override `transferOwnership` to change the `_owner` in this contract.
    function transferOwnership(address newOwner) public override onlyOwner {
        _owner = newOwner;
        super.transferOwnership(newOwner);
    }
}
