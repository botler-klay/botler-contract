const HDWalletProvider = require('@truffle/hdwallet-provider');

const dotenv = require('dotenv');
dotenv.config();

const privateKey = process.env.DEPLOYER_WALLET_PRIVATEKEY;
const testnetNode = process.env.KLAYTN_TESTNET_NODE_URI;
const mainnetNode = process.env.KLAYTN_MAINNET_NODE_URI;

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 7545,
      network_id: "5777"
    },
    testnet: {
      provider: () => new HDWalletProvider(privateKey, testnetNode),
      network_id: '1001',
      gas: '8000000',
      gasPrice: '750000000000'
    },
    mainnet: {
      provider: () => new HDWalletProvider(privateKey, mainnetNode),
      network_id: '8217',
      gas: '80000000',
      gasPrice: null
    }
  },

  mocha: {
    // timeout: 100000
  },

  compilers: {
    solc: {
      version: "0.8.1",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        },
      }
    }
  }
};
