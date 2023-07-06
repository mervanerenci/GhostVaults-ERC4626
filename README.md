# GhostVaults

GhostVaults Project consists of two contracts: a User contract for manual testing logics and user interactions, and a GhostVault ERC4626 Vaults contract for managing the GhostVaults themselves.

## GhostVault
GhostVault is a smart contract that allows users to deposit and withdraw ERC20 tokens using the Aave lending pool. Users can earn interest on their deposits and redeem their shares at any time.

### Features
- GhostVault is an ERC4626 implementation, which means it follows the standard interface for vaults that hold ERC20 tokens.
- GhostVault uses the Aave lending pool to lend and borrow tokens, and the Aave price oracle to get the current market prices of the tokens.
- GhostVault supports any ERC20 token that is compatible with the Aave lending pool, but currently only USDC is enabled.
- GhostVault mints and burns shares for each deposit and withdrawal, which represent the user’s proportional claim on the underlying assets.
- GhostVault has a simple and transparent fee structure, which is deducted from the interest earned by the vault.






## User Contract
The User contract is a Solidity smart contract that facilitates user interactions and transactions. It allows users to deposit and withdraw USDC tokens to and from a vault, as well as send tokens to multiple recipients using a batcher contract.

### Example Usage
Here's an example of how to use the User contract:

1. Deploy the User contract by providing the vault contract address.
2. Call the setVault function if you want to change the vault address.
3. Call the depositUSDC function, specifying the amount of USDC tokens you want to deposit.
4. Call the withdrawUSDC function, specifying the amount of USDC tokens you want to withdraw.
5. Approve the User contract to spend USDC tokens on your behalf.
6. Call the sendToMultipleRecipients function, specifying the token address, recipient addresses, and corresponding amounts.
7. Interact with the contract by sending USDC tokens to its address.

