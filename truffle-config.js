require("babel-register");
require("babel-polyfill");
require("dotenv").config();
const HDWalletProvider = require("@truffle/hdwallet-provider");

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*",
    },
    live: {
      provider: () => {
        return new HDWalletProvider(process.env.MNEMONIC, process.env.RPC_URL);
      },
      network_id: "4",
      timeoutBlocks: 50000,
      skipDryRun: true,
    },
  },
  contracts_directory: "./src/contracts/",
  contracts_build_directory: "./src/abis/",
  compilers: {
    solc: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      version: "0.6.0",
      evmVersion: "petersburg",
    },
  },
  plugins: ["truffle-plugin-verify"],
  api_keys: {
    etherscan: process.env.ETHERSCAN_API_KEY,
  },
};
