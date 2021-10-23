# Dependencies
Ensure you have the following tools installed on your system: *nodejs, npm, yarn, git*

# How to deploy
1. Clone and install this github project using the following commands.
    ```
    git clone <repo_url>
    cd wrapped-x-invites/hardhat
    yarn install
    ```
2. Edit **wrapped-x-invites/hardhat/example.env**, filling in the blank strings
3. Rename the above edited file to **wrapped-x-invites/hardhat/.env**
4. Ensure that the wallet associated with MAINNET_PRIVATE_KEY from the .env file edited above has enough ETH to successfully deploy WrappedXInvites.sol (wallet should have ~.3 ETH at minimum)
5. Then run:
   ```
   yarn deploy-mainnet
   ```
6. Confirm that the contract is deployed by entering the TX hash of the deployment into etherscan
7. You can change the NFT URI admin to a more secure wallet you control using the **updateURIAdmin** function on the deployed contract. Tip: use [https://app.mycrypto.com](https://app.mycrypto.com) to interact with the deployed contract.
8. You can also adjust the fee required to use the contract using **updateDevFee** as well as who recieves the dev fee by calling **updateDevFeeCollector**. Initially the dev fee collector address is set to the wallet responsible for deploying the contract and the dev fee is set to .05 ETH, collected on **mintInviteNFT** and **useAndGenerateInviteNFT** functions. 
   
# How the deployed contract works

Any holder of $X that has not yet spent their invite can mint an NFT using the WrappedXInvites.sol contract. All that's required is that you own .01 $X and that you have not spent your first invite. The NFT minted can be "used" at any time by someone not yet invited into $X. When the initial minter transfers/sells the NFT to the uninvited account the receiver can then "use" the NFT to gain access $X. The .01 $X gets continually recycled into new invite NFTs. After an NFT is "used" a new one is automatically generated and credited to the account that just used the NFT. 

# Example
* Roger owns 1.00 $X and has not yet invited anyone
* Roger calls **mintInviteNFT()** on WrappedXInvites.sol
* As a result Roger now owns .99 $X and WrappedXInvites NFT #1 that represents a single invite to $X
* Roger lists the NFT on opensea and sells it for 2 ETH to Kelly, who does not own and cannot buy $X
* After the sale and transfer is complete, Kelly calls **useAndGenerateInviteNFT(1)** on WrappedXInvites.sol
* As a result Kelly now owns WrappedXInvites NFT #2 but still no $X
* But, because Kelly successfully called **useAndGenerateInviteNFT(1)** above, she can now buy $X on any exchange she wants
* Since Kelly doesn't need NFT #2, she can relist it on Opensea and recoup here original investment

# Motivation 
Before a market arises for $X, the unspent invites are by far the most valuable aspect of $X. By locking away the least amount of $X possible to create invite NFTs, price discovery on platforms like Opensea is possible. Furthermore, price discover for invites to $X will ultimately incentive inviting new $X holders, growing the $X user base. 