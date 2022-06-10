import { task } from 'hardhat/config';

task('accounts', 'Prints the list of accounts', async (_taskArgs, { ethers }) => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(await account.getAddress());
  }
});
