import { task } from 'hardhat/config';

import type { TaskArguments } from 'hardhat/types';

task('deploy:AppRegistry').setAction(
  async (_taskArguments: TaskArguments, { ethers }) => {
    const signers = await ethers.getSigners();

    const AppRegistry = await ethers.getContractFactory('AppRegistry');
    const registry = await AppRegistry.connect(signers[0]).deploy();

    await registry.deployed();

    console.log('AppRegistry deployed to:', registry.address);
  }
);
