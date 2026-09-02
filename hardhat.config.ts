import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import "@openzeppelin/hardhat-upgrades";
import "@onmychain/hardhat-uniswap-v2-deploy-plugin";

import * as dotenv from "dotenv";
dotenv.config();

const MAINNET_TEST_KEY = process.env.MAINNET_TEST_KEY || "";
const MAINNET_KEY = process.env.MAINNET_KEY || "";


const config: HardhatUserConfig = {
  networks: {
    hardhat: {
    },
    bscTestnet: {
      url: "https://data-seed-prebsc-1-s1.bnbchain.org:8545",
      chainId: 97,
      accounts: [MAINNET_TEST_KEY],
    },
    bsc: {
      url: "https://bsc-dataseed4.bnbchain.org",
      chainId: 56,
      accounts: [MAINNET_KEY],
    },
   
  },
  solidity: {
    compilers: [
      {
        version: "0.8.20",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
      {
        version: "0.8.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
      {
        version: "0.8.3",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          },
          outputSelection: {
            "*": {
              "*": ["storageLayout"]
            }
          }
        }
      },
      {
        version: "0.6.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          },
          outputSelection: {
            "*": {
              "*": ["storageLayout"]
            }
          }
        }
      },
      {
        version: "0.6.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          },
          outputSelection: {
            "*": {
              "*": ["storageLayout"]
            }
          }
        }
      },
      {
        version: "0.5.16",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          },
          outputSelection: {
            "*": {
              "*": ["storageLayout"]
            }
          }
        }
      },
      {
        version: "0.4.22",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          },
          outputSelection: {
            "*": {
              "*": ["storageLayout"]
            }
          }
        }
      },
    ],
  },
  mocha: {
    timeout: 500000,
  },
  etherscan: {
    enabled: true,
    apiKey: "3J6H4HG43P1EE9PMH8R55ERDCTRE1PC5BC",
    // apiKey: {
    //   bsc: "3J6H4HG43P1EE9PMH8R55ERDCTRE1PC5BC"
    // },

    // customChains: [
    //   {
    //     network: "bsc",
    //     chainId: 56,
    //     urls: {
    //       // apiURL: "https://api.etherscan.io/v2/api?chainid=56&apikey=3J6H4HG43P1EE9PMH8R55ERDCTRE1PC5BC",
    //       // apiURL: "https://api.etherscan.io/v2/api?chainid=56",
    //       apiURL: "https://api.bscscan.com/api",
    //       browserURL: "https://bscscan.com/"
    //     }
    //   }
    // ],

    // apiKey: {
    //   bscTestnet: "SX4ZSNXD39A54A94QIVH8Q92EEK5GDSZRD",
    //   // bsc: "SX4ZSNXD39A54A94QIVH8Q92EEK5GDSZRD"
    //   // bsc: "3J6H4HG43P1EE9PMH8R55ERDCTRE1PC5BC"
    //   bsc: "https://api.etherscan.io/v2/api?chainid=56&action=balance&apikey=3J6H4HG43P1EE9PMH8R55ERDCTRE1PC5BC"
    // }
  },
  sourcify: {
    enabled: false,
  },
};

export default config;
