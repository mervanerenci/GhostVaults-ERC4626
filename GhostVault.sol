// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {ERC4626} from "https://github.com/transmissions11/solmate/blob/main/src/mixins/ERC4626.sol";
import {IPool} from "https://github.com/aave/aave-v3-core/blob/master/contracts/interfaces/IPool.sol";
import {IPoolAddressesProvider} from "https://github.com/aave/aave-v3-core/blob/master/contracts/interfaces/IPoolAddressesProvider.sol";
import {IPriceOracle} from "https://github.com/aave/aave-v3-core/blob/master/contracts/interfaces/IPriceOracle.sol";
import {IERC4626} from "./interfaces/IERC4626.sol";
import {ERC4626} from "https://github.com/transmissions11/solmate/blob/main/src/mixins/ERC4626.sol";
import {ERC20} from "https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol";

/**
 * @title GhostVault Contract
 * @dev Ghost Vaults are simple ERC4626 implementations. Managing deposit and withdrawal of assets using Aave lending pool. 
 * @dev GhostVault is currnetly deployed at "0x1157CFdd7Ea635c4a6f6E8a525B45EA58256160E" address on Mumbai testnet. 
 * @dev GhostVault 
 */
contract GhostVault is ERC4626 {

    address private constant POOL_ADDRESS_PROVIDER = 0xeb7A892BB04A8f836bDEeBbf60897A7Af1Bf5d7F;
    address constant USDC_ADDRESS = 0xe9DcE89B076BA6107Bb64EF30678efec11939234;

    address private AAVE_LENDING_POOL_ADDRESS; 
    address private PRICE_ORACLE;

    mapping(address => uint256) public balances;
    IPool private lendingPool;
    IPriceOracle private priceOracle;


    /*//////////////////////////////////////////////////////////////
                               IMMUTABLE
    //////////////////////////////////////////////////////////////*/


    constructor(
        ERC20 _token,
        string memory _name,
        string memory _symbol
    ) ERC4626(_token, _name, _symbol) {
        IPoolAddressesProvider provider = IPoolAddressesProvider(POOL_ADDRESS_PROVIDER);
        AAVE_LENDING_POOL_ADDRESS = provider.getPool();
        lendingPool = IPool(AAVE_LENDING_POOL_ADDRESS);
        priceOracle = IPriceOracle(PRICE_ORACLE);
    }



    /*//////////////////////////////////////////////////////////////
                        DEPOSIT/WITHDRAWAL LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Deposit assets into the GhostVault and mint corresponding shares.
     * @param assets The amount of assets to deposit.
     * @param receiver The address to receive the minted shares.
     * @return shares The number of shares minted.
     */
    function deposit(uint256 assets, address receiver) public virtual override returns (uint256 shares) {
        require((shares = previewDeposit(assets)) != 0, "ZERO_SHARES");
        asset.transferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assets, shares);
        afterDeposit(assets, shares);
    }

    /**
     * @dev Withdraw assets from the GhostVault and burn corresponding shares.
     * @param assets The amount of assets to withdraw.
     * @param receiver The address to receive the withdrawn assets.
     * @param owner The owner of the shares being burned.
     * @return shares The number of shares burned.
     */
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public virtual override returns (uint256 shares) {
        shares = previewWithdraw(assets);
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender];
            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }
        beforeWithdraw(assets,
        shares);

        _burn(owner, shares);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);

        asset.transferFrom(address(this), receiver, assets);
    }

    /**
     * @dev Perform actions after depositing assets into the GhostVault.
     * @param assets The amount of assets deposited.
     
     */
    function afterDeposit(uint256 assets, uint256 /*shares*/) internal virtual override {
        // Approve lending pool to use tokens from this smart contract
        asset.approve(AAVE_LENDING_POOL_ADDRESS, assets);

        // Deposit tokens to the Aave lending pool
        lendingPool.supply(address(asset), assets, address(this), 0);
    }

    /**
     * @dev Perform actions before withdrawing assets from the GhostVault.
     * @param assets The amount of assets to withdraw.
     */
    function beforeWithdraw(uint256 assets, uint256 /*shares*/) internal virtual override {
        // Withdraw tokens directly from Aave to user
        lendingPool.withdraw(address(asset), assets, msg.sender);
    }



    
    /*//////////////////////////////////////////////////////////////
                            ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Get the total assets held by the GhostVault.
     * @return The total amount of assets held.
     */
    function totalAssets() public view virtual override returns (uint256) {
        return asset.balanceOf(address(this));
    }

    /**
     * @dev Convert the given amount of assets to shares.
     * @param assets The amount of assets to convert.
     * @return The number of shares corresponding to the given assets.
     */
    function convertToShares(uint256 assets) public view virtual override returns (uint256) {
        uint256 supply = assets;
        return supply;
    }

    /**
     * @dev Convert the given number of shares to assets.
     * @param shares The number of shares to convert.
     * @return The amount of assets corresponding to the given shares.
     */
    function convertToAssets(uint256 shares) public view virtual override returns (uint256) {
        uint256 supply = shares;
        return supply;
    }

    /**
     * @dev Preview the number of shares that will be minted for the given amount of assets.
     * @param assets The amount of assets to deposit.
     * @return The number of shares that will be minted.
     */
    function previewDeposit(uint256 assets) public view virtual override returns (uint256) {
        return convertToShares(assets);
    }

    /**
     * @dev Preview the number of shares that will be burned for the given amount of assets to withdraw.
     * @param assets The amount of assets to withdraw.
     * @return The number of shares that will be burned.
     */
    function previewWithdraw(uint256 assets) public view virtual override returns (uint256) {
        uint256 supply = assets;
        return supply;
    }

    /**
     * @dev Preview the amount of assets that will be redeemed for the given number of shares.
     * @param shares The number of shares to redeem.
     * @return The amount of assets that will be redeemed.
     */
    function previewRedeem(uint256 shares) public view virtual override returns (uint256) {
        return convertToAssets(shares);
    }


    /*//////////////////////////////////////////////////////////////
                            HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/


    /**
     * @dev Get the price of the asset held by the GhostVault.
     * @return The price of the asset.
     */
    function getAssetPrice( ) public view  returns (uint256) {

        return priceOracle.getAssetPrice(USDC_ADDRESS);

    }

        
}
