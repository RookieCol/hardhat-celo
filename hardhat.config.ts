// Import necessary modules
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from 'dotenv';

// Load environment variables from the .env file
dotenv.config();

// Check if PRIVATE_KEY is set in the .env file
if (!process.env.PRIVATE_KEY) {
  throw new Error("PRIVATE_KEY is not defined in .env file");
}

// Check if ETHERSCAN_API_KEY is set in the .env file
if (!process.env.ETHERSCAN_CELO_API_KEY) {
  throw new Error("ETHERSCAN_API_KEY is not defined in .env file");
}

// Hardhat configuration
const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    alfajores: {
      url: "https://alfajores-forno.celo-testnet.org",
      chainId: 44787,
      accounts: [process.env.PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: {
      alfajores: process.env.ETHERSCAN_CELO_API_KEY
    },
    customChains: [
      {
        network: "alfajores",
        chainId: 44787,
        urls: {
          apiURL: "https://api-alfajores.celoscan.io/api",
          browserURL: "https://alfajores.celoscan.io",
        }
      }
    ]
  },
  defaultNetwork: "alfajores"
};

export default config;
