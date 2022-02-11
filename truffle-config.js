const HDWalletProvider = require('@truffle/hdwallet-provider');
const { privateKey, apiKey } = require('./secret.json');
module.exports = {

  networks: {

    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 8545,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
    },

    rinkeby: {
      provider: () => new HDWalletProvider(privateKey, `https://rinkeby.infura.io/v3/${apiKey}`),
      network_id: 4,
      gas: 5500000,
      // networkCheckTimeout: 1000000,
      // disableConfirmationListener: true,
      // confirmations: 2,
      // timeoutBlocks: 50,
      skipDryRun: true
    },
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.11",    // Fetch exact version from solc-bin (default: truffle's version)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: false,
          runs: 200
        },
        // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
        //  evmVersion: "byzantium"
      }
    }
  }
}
