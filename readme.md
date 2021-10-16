ONLY ON ROPSTEN! Mainnet Coming Soon ™

#### Ropsten FakeX.sol address: 0x5535196a216AC1306b0044F574fdfb6Cd4032479 (mock $X contract)
#### Ropsten WrappedXInvites.sol address: 0x198729b9B0bA27207D8da8EDC440a1a0f66283d5

# How it works

Any holder of $X that has not yet spent their invite can mint an NFT using the WrappedXInvites.sol contract. All that's required is that you own .01 $X and that you have not spent your first invite. The NFT minted can be "used" at any time by someone not yet invited into $X. When the initial minter transfers/sells the NFT to the uninvited account the receiver can then "use" the NFT to gain access $X. The .01 $X gets continually recycled into new invite NFTs. After an NFT is "used" a new one is automatically generated and credited to the account that just used the NFT. Invites are maximally capital efficient.

# Example
* Roger owns 1.00 $X and has not yet invited anyone
* Roger calls mintInviteNFT() on WrappedXInvites.sol
* As a result Roger now owns .99 $X and WrappedXInvites NFT #1 that represents a single invite to $X
* Roger lists the NFT on opensea and sells it for 2 ETH to Kelly, who does not own and cannot buy $X
* After the sale and transfer is complete, Kelly calls useAndGenerateInviteNFT(1) on WrappedXInvites.sol
* As a result Kelly now owns WrappedXInvites NFT #2 but still no $X
* But, because Kelly successfully called useAndGenerateInviteNFT(1) above, she can now buy $X on any exchange she wants
* Since Kelly doesn't need NFT #2, she can relist it on Opensea and recoup here original investment

# Are there fees?
No. Just gas on the Ethereum network.

# Will these NFTs come with artwork?
That depends. I would love to collab with an artist to build a generative art framework for each invite NFT.

# Motivation 
Before a market arises for $X, the unspent invites are by far the most valuable aspect of $X. By locking away the least amount of $X possible to create invite NFTs, price discovery on platforms like Opensea is possible. Furthermore, price discover for invites to $X will ultimately incentive inviting new $X holders, growing the $X user base. 