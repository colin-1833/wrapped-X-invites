import { HardhatUserConfig } from 'hardhat/config';
import * as path from 'path';
import * as fs from 'fs';
import '@nomiclabs/hardhat-waffle';
import '@nomiclabs/hardhat-ethers';
import 'hardhat-deploy'
import 'hardhat-contract-sizer';
import 'hardhat-gas-reporter';
import * as dotenv from 'dotenv';

const path_to_env = path.resolve(__dirname, './.env');

if (!fs.existsSync(path_to_env)) {
    throw new Error('.env file was not found!')
}

dotenv.config({ path: path_to_env });

const config: HardhatUserConfig = {
    gasReporter: {
        currency: 'USD',
        coinmarketcap: process.env.COINMARKETCAP_API_KEY
    },
    networks: {
        hardhat: {
            chainId: 1337
        },
        ropsten: {
            chainId: 3,
            url: process.env.ROPSTEN_INFURA,
            accounts: [process.env.ROPSTEN_PRIVATE_KEY]
        },
        mainnet: {
            chainId: 1,
            url: process.env.MAINNET_INFURA,
            accounts: [process.env.MAINNET_PRIVATE_KEY]
        }
    },
    solidity: {
        compilers: [
            {
                version: '0.8.6'
            }
        ]
    },
    paths: {

    },
    contractSizer: {
        alphaSort: false,
        runOnCompile: false,
        disambiguatePaths: false,
    }
};

export default config;
