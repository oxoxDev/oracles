import "@nomicfoundation/hardhat-ethers";
import "hardhat-deploy";
import "@nomicfoundation/hardhat-verify";

import dotenv from "dotenv";
dotenv.config();

import "./tasks/deploy-api3";
import "./tasks/deploy-api3-eth";
import "./tasks/deploy-pyth";
import "./tasks/deploy-contract";
import "./tasks/deploy-double-agg";
import "./tasks/update-pyth";
import "./tasks/get-pyth-data";
import "./tasks/update-pyth-feeds";

export default {
  solidity: "0.8.20",
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      forking: {
        url: `https://mainnet.base.org/`,
        // url: `https://cloudflare-eth.com`,
      },
    },
    blast: {
      url: `https://rpc.blast.io`,
      accounts: [process.env.WALLET_PRIVATE_KEY || ""],
    },
    mainnet: {
      // url: `https://cloudflare-eth.com`,
      url: `https://rpc.ankr.com/eth`,
      saveDeployments: true,
      // gasPrice: 2000000000,
      accounts: [process.env.WALLET_PRIVATE_KEY || ""],
    },
    linea: {
      url: `https://rpc.linea.build/`,
      accounts: [process.env.WALLET_PRIVATE_KEY || ""],
    },
    base: {
      url: `https://mainnet.base.org/`,
      accounts: [process.env.WALLET_PRIVATE_KEY || ""],
    },
    zircuit: {
      url: `https://zircuit-mainnet.drpc.org`,
      accounts: [process.env.WALLET_PRIVATE_KEY || ""],
    },
    era: {
      url: `https://mainnet.era.zksync.io`,
      accounts: [process.env.WALLET_PRIVATE_KEY || ""],
    },
    manta: {
      url: `https://pacific-rpc.manta.network/http`,
      accounts: [process.env.WALLET_PRIVATE_KEY || ""],
    },
    berachain: {
      url: `https://rpc.berachain.com`,
      accounts: [process.env.WALLET_PRIVATE_KEY || ""],
    },
    mezo: {
      url: `https://jsonrpc-mezo.boar.network`,
      accounts: [process.env.WALLET_PRIVATE_KEY || ""],
    },
  },
  etherscan: {
    apiKey: {
      blast: process.env.BLASTSCAN_KEY || "",
      base: process.env.BASESCAN_KEY || "",
      linea: process.env.LINEASCAN_KEY || "",
      xLayer: process.env.XLAYER_KEY || "",
      zircuit: process.env.ZIRCUIT_KEY || "",
      mainnet: process.env.ETHERSCAN_KEY || "",
      berachain: process.env.BERASCAN_KEY || "",
      manta: "",
      era: process.env.ZKSYNC_KEY || "",
      mezo:"TEST",
    },
    customChains: [
      {
        network: "manta",
        chainId: 169,
        urls: {
          apiURL: "https://pacific-explorer.manta.network/api",
          browserURL: "https://pacific-explorer.manta.network",
        },
      },
      {
        network: "berachain",
        chainId: 80094,
        urls: {
          apiURL: "https://api.berascan.com/api",
          browserURL: "https://berascan.com",
        },
      },
      {
        network: "linea",
        chainId: 59144,
        urls: {
          apiURL: "https://api.lineascan.build/api",
          browserURL: "https://lineascan.build",
        },
      },
      {
        network: "blast",
        chainId: 81457,
        urls: {
          apiURL: "https://api.blastscan.io/api",
          browserURL: "https://blastscan.io",
        },
      },
      {
        network: "xLayer",
        chainId: 196,
        urls: {
          apiURL:
            "https://www.oklink.com/api/v5/explorer/contract/verify-source-code-plugin/XLAYER",
          browserURL: "https://www.oklink.com/xlayer", //or https://www.oklink.com/xlayer for mainnet
        },
      },
      {
        network: "zircuit",
        chainId: 48900,
        urls: {
          apiURL: "https://explorer.zircuit.com/api/contractVerifyHardhat",
          browserURL: "https://explorer.zircuit.com",
        },
      },
      {
        network: "mezo",
        chainId: 31612,
        urls: {
          apiURL: "https://api.explorer.mezo.org/api",
          browserURL: "https://explorer.mezo.org"
        }
      },
    ],
  },
};
