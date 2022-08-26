# Any funder

Decentralized sponsorship for everyone ✨

## 📚 Project walkthrough

This project ships with 2 main contracts,

- `AppRegistry.sol` - This is the registry if you're making a funding app to support multiple users
  and handle their contract deployment and unloading.
- `AnyFunder.sol` - This is the main app that is used on per-user basis. It has functions to pay an user in any
  currency you like and it's automatically swapped (thanks to uniswap protocols!) to the currency specified by
  the owner. And, you can withdraw all the funds that you have (native token/erc20) using the withdraw function.

The project also ships with a lot of useful libraries that you can use aswell for functionalities related
to currency handling.

- `CurrencyWrapper.sol` - This library has the functionality to wrap and unwrap native/erc20 tokens respectively.
  For example, you can wrap eth as weth, and unwrap it back. This works for _any_ native token and it's wrapped
  erc20 token format!
- `CurrencyTransfer.sol` - Having issues writing code to transfer funds, not anymore. This has options to transfer
  native token/erc20 funds easily, anywhere.
- `CurrencySwapper.sol` - The heart of this app - swapping mechanism with a lot of checks and edge case handling
  to make swapping native-erc20 tokens and vice versa easy in uniswap v3.

_Psst - we're looking to add a lot of amazing features for everyone, even features such as events and
crowdfunding!_

## 👇 Pre-requisites

Ensure that you have the following tools ready and installed to use this:

- Git
- Node.js

Setup the environmental variables if you haven't yet.

You can setup the `.env` variables based on the `.env.example` file as provided. Setup the file using
`cp .env.example .env` and fill in the values.

## 🛠 Usage

Quickly get started by installing the dependencies.

```sh
npm install -D
# OR
yarn
```

Then, compile the contracts using:

```sh
npm run build
# OR
yarn run build
```

This should compile everything, aswell export ABIs into the `abis/` folder.

Now, you're good to go to start using the contracts in your app.

## Contributing

Contributions, issues and feature requests are welcome. After cloning & setting up project locally, you
can just submit a PR to this repo and it will be deployed once it's accepted.

⚠️ It’s good to have descriptive commit messages, or PR titles so that other contributors can understand about your
commit or the PR Created. Read [conventional commits](https://www.conventionalcommits.org/en/v1.0.0-beta.3/)
before making the commit message.

## Show your support

We love people's support in growing and improving. Be sure to leave a ⭐️ if you like the project and
also be sure to contribute, if you're interested!

<div align="center">Made by Sunrit Jana with ❤</div>
