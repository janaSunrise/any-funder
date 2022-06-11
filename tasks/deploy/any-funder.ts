import { task } from 'hardhat/config';

import type { TaskArguments } from 'hardhat/types';

task('deploy:AnyFunder')
  .addParam(
    'currency',
    'The currency adress for the owner to receive payment in'
  )
  .addParam('wrappedtoken', 'The wrapped token address for the specific chain')
  .addParam('router', 'The address for the uniswap swap router')
  .setAction(async (taskArguments: TaskArguments, { ethers }) => {
    const signers = await ethers.getSigners();

    const AnyFunder = await ethers.getContractFactory('AnyFunder');
    const funder = await AnyFunder.connect(signers[0]).deploy(
      taskArguments.currency,
      taskArguments.wrappedtoken,
      taskArguments.router
    );

    await funder.deployed();

    console.log('AnyFunder deployed to:', funder.address);
  });
