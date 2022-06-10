import '@typechain/hardhat';
import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-waffle';
import 'hardhat-gas-reporter';

import dotenv from 'dotenv';
import { HardhatUserConfig } from 'hardhat/config';
import { NetworkUserConfig } from 'hardhat/types';

import './tasks';

dotenv.config();

const alchemyKey: string = process.env.ALCHEMY_KEY || '';
const accountPrivateKey: string = process.env.ACCOUNT_PRIVATE_KEY || '';

// Chain IDs and RPC URLs.
interface RpcAndChainId {
  chainId: number;
  rpcUrl: string;
}

const chainInfo: Record<string, RpcAndChainId> = {
  // Ethereum
  mainnet: {
    chainId: 1,
    rpcUrl: `https://eth-mainnet.alchemyapi.io/v2/${alchemyKey}`
  },
  ropsten: {
    chainId: 3,
    rpcUrl: `https://eth-ropsten.alchemyapi.io/v2/${alchemyKey}`
  },
  rinkeby: {
    chainId: 4,
    rpcUrl: `https://eth-rinkeby.alchemyapi.io/v2/${alchemyKey}`
  },
  goerli: {
    chainId: 5,
    rpcUrl: `https://eth-goerli.alchemyapi.io/v2/${alchemyKey}`
  },
  kovan: {
    chainId: 42,
    rpcUrl: `https://eth-kovan.alchemyapi.io/v2/${alchemyKey}`
  },

  // Polygon
  polygon: {
    chainId: 137,
    rpcUrl: `https://polygon-mainnet.g.alchemy.com/v2/${alchemyKey}`
  },
  mumbai: {
    chainId: 80001,
    rpcUrl: `https://polygon-mumbai.g.alchemy.com/v2/${alchemyKey}`
  },

  // Avax
  avax: { chainId: 43114, rpcUrl: 'https://api.avax.network/ext/bc/C/rpc' },
  avax_testnet: {
    chainId: 43113,
    rpcUrl: 'https://api.avax-test.network/ext/bc/C/rpc'
  },

  // Fantom
  fantom: { chainId: 250, rpcUrl: 'https://rpc.ftm.tools' },
  fantom_testnet: {
    chainId: 4002,
    rpcUrl: 'https://rpc.testnet.fantom.network'
  }
};

// Generating network config.
const generateNetworkConfig = (
  networkName: keyof typeof chainInfo
): NetworkUserConfig => {
  if (!alchemyKey) {
    throw new Error(
      'Please set ALCHEMY_KEY environment variable to your Alchemy API key.'
    );
  }

  const { chainId, rpcUrl } = chainInfo[networkName];

  return {
    chainId: chainId,
    url: rpcUrl,
    accounts: [accountPrivateKey]
  };
};

// Configuration.
const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.9',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
      metadata: {
        bytecodeHash: 'none'
      }
    }
  },
  typechain: {
    outDir: 'typechain',
    target: 'ethers-v5'
  },
  gasReporter: {
    currency: 'USD',
    enabled: process.env.REPORT_GAS ? true : false
  }
};

// Network configuration.
if (accountPrivateKey) {
  config.networks = {
    // Ethereum
    mainnet: generateNetworkConfig('mainnet'),
    ropsten: generateNetworkConfig('ropsten'),
    rinkeby: generateNetworkConfig('rinkeby'),
    goerli: generateNetworkConfig('goerli'),
    kovan: generateNetworkConfig('kovan'),

    // Polygon
    polygon: generateNetworkConfig('polygon'),
    mumbai: generateNetworkConfig('mumbai'),

    // Avax
    avax: generateNetworkConfig('avax'),
    avax_testnet: generateNetworkConfig('avax_testnet'),

    // Fantom
    fantom: generateNetworkConfig('fantom'),
    fantom_testnet: generateNetworkConfig('fantom_testnet')
  };
}

config.networks = {
  ...config.networks,
  hardhat: {
    chainId: 1337
  }
};

export default config;
