import chai, { expect } from 'chai';
import { ethers } from 'hardhat';

import { solidity } from 'ethereum-waffle';

import type { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import type { Contract } from 'ethers';

chai.use(solidity);

describe('Greeter', () => {
  let greeter: Contract;

  let owner: SignerWithAddress;

  before(async () => {
    [owner] = await ethers.getSigners();
  });

  beforeEach(async () => {
    const Greeter = await ethers.getContractFactory('Greeter');

    greeter = await Greeter.deploy('Hello, world!');

    await greeter.deployed();
  });

  it('Should have `Hello, World` as default greeting', async () => {
    expect(await greeter.greet()).to.equal('Hello, world!');
  });

  it("Should return the new greeting once it's changed", async () => {
    const setGreetingTx = await greeter.setGreeting('Hola, mundo!');

    await setGreetingTx.wait();

    expect(await greeter.greet()).to.equal('Hola, mundo!');
  });
});
