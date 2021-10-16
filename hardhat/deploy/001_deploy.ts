
import { DeployFunction } from 'hardhat-deploy/types';
import type { HardhatRuntimeEnvironment } from 'hardhat/types';
import {
    load_env,
    use_deployments
} from '../utils/index';

import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-waffle';
import 'hardhat-deploy';

load_env();

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const [deployer] = await hre.ethers.getUnnamedSigners();
    const {
        deploy_fx,
        deploy_wx_dev,
        deploy_wx_mainnet
    } = use_deployments(hre);
    if (hre.network.config.chainId === 1) {
        await deploy_wx_mainnet(process.env.CUSTOM_URI_BASE);
        return;
    }
    if (hre.network.config.chainId === 3) {
        const FakeX = await deploy_fx();
        await deploy_wx_dev(FakeX(deployer).address);
        return;
    }
    if (hre.network.config.chainId === 1337) {
        await deploy_wx_dev(await deploy_fx());
        return;
    }
    throw new Error('Unsupported testnet with chainId: ' + hre.network.config.chainId);
};
export default func;
func.tags = ['Legendeth'];
