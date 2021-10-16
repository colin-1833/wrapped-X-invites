import { DeployOptions } from 'hardhat-deploy/types';
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { ethers } from 'hardhat';
import type { Signer, Contract, BigNumber } from 'ethers';
import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-waffle';
import 'hardhat-deploy';
import * as fs from 'fs';
import * as path from 'path';
import * as dotenv from 'dotenv';

export interface Accounts {
    deployer: Signer|null,
    others: Array<Signer>
}

export const load_env = () => {
    const path_to_env = path.resolve(__dirname, '../.env');
    if (!fs.existsSync(path_to_env)) {
        fs.writeFileSync(path_to_env, '');
    }
    dotenv.config({ path: path_to_env });
};

export const get_accounts = (hre: HardhatRuntimeEnvironment): Promise<Accounts> => new Promise(async (resolve, reject) => { try {
    const unnamed_signers = await hre.ethers.getUnnamedSigners();
    resolve({
        deployer: unnamed_signers[0],
        others: unnamed_signers.slice(1)
    });
} catch (err) { reject(err) }});

export type UseContract = (signer: Signer) => Contract;

export const deploy = (
    hre: HardhatRuntimeEnvironment,
    contract_name: string,
    deploy_options: DeployOptions
): Promise<UseContract> => new Promise(async (resolve, reject) => {
    try {
        const { deployments } = hre;
        const { deploy: _deploy } = deployments;
        const { address } = await _deploy(contract_name, deploy_options);
        const Contract = (await ethers.getContractFactory(contract_name)).attach(address);
        console.log('    Deployed contract: ' + contract_name);
        resolve((signer: Signer) => Contract.connect(signer));
    } catch (err) { reject(err) }
});

export const use_deployments = (hre: HardhatRuntimeEnvironment): any => {
    return {
        deploy_fx: (): Promise<UseContract> => new Promise(async (resolve, reject) => { try {
            const accounts = await get_accounts(hre);
            const FakeX = await deploy(hre, 'FakeX', {
                from: await accounts.deployer.getAddress(),
                args: []
            });
            await (await FakeX(accounts.deployer).mint(await accounts.deployer.getAddress(), 100))
                .wait(1);
            resolve(FakeX);
        } catch (err) { reject(err) }}),


        deploy_wx_dev: (X_address: string): Promise<UseContract> => new Promise(async (resolve, reject) => { try {
            const accounts = await get_accounts(hre);
            const WrappedXInvites = await deploy(hre, 'WrappedXInvites', {
                from: await accounts.deployer.getAddress(),
                args: [X_address, "https://picsum.photos/200/300?random="]
            });
            console.log('Deployed WrappedXInvites at: ' + WrappedXInvites(accounts.deployer).address);
            resolve(WrappedXInvites);
        } catch (err) { reject(err) }}),  

        deploy_wx_mainnet: (mainnet_art_uri: string): Promise<UseContract> => new Promise(async (resolve, reject) => { try {
            const accounts = await get_accounts(hre);
            const WrappedXInvites = await deploy(hre, 'WrappedXInvites', {
                from: await accounts.deployer.getAddress(),
                args: ["0xA396Dac0BaBc6126dffD48b331495a13d31ba8a3", mainnet_art_uri]
            });
            console.log('Deployed WrappedXInvites at: ' + WrappedXInvites(accounts.deployer).address);
            resolve(WrappedXInvites);
        } catch (err) { reject(err) }})
    };
};