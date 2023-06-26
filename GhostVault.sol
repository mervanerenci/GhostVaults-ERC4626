//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {ERC4626} from "https://github.com/transmissions11/solmate/blob/main/src/mixins/ERC4626.sol";
import {IPool} from "https://github.com/aave/aave-v3-core/blob/master/contracts/interfaces/IPool.sol";
import {IPoolAddressesProvider} from "https://github.com/aave/aave-v3-core/blob/master/contracts/interfaces/IPoolAddressesProvider.sol";
import {IPriceOracle} from "https://github.com/aave/aave-v3-core/blob/master/contracts/interfaces/IPriceOracle.sol";

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract GhostVault is ERC4626 {

    // address constant USDC_ADDRESS = 0xe9DcE89B076BA6107Bb64EF30678efec11939234;
    address private constant POOL_ADDRESS_PROVIDER = 0xeb7A892BB04A8f836bDEeBbf60897A7Af1Bf5d7F;
    address private AAVE_LENDING_POOL_ADDRESS; 
    address private  PRICE_ORACLE;
    
    
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
    ) ERC4626(_token, _name, _symbol)  {
        
        IPoolAddressesProvider provider = IPoolAddressesProvider(POOL_ADDRESS_PROVIDER);
        AAVE_LENDING_POOL_ADDRESS = provider.getPool();
        lendingPool = IPool(AAVE_LENDING_POOL_ADDRESS);
        priceOracle = IPriceOracle(PRICE_ORACLE);
    }

    /*//////////////////////////////////////////////////////////////
                        DEPOSIT/WITHDRAWAL LOGIC
    //////////////////////////////////////////////////////////////*/

    function deposit(uint256 assets, address receiver) public virtual override returns (uint256 shares) {
        // Check for rounding error since we round down in previewDeposit.
        require((shares = previewDeposit(assets)) != 0, "ZERO_SHARES");

        // Need to transfer before minting or ERC777s could reenter.
        asset.transferFrom(msg.sender, address(this), assets);

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);

        afterDeposit(assets, shares);
    }

    function afterDeposit(uint256 assets, uint256 /*shares*/) internal virtual override {
    
        // Approve lending pool to use  tokens from this smart contract
        asset.approve(AAVE_LENDING_POOL_ADDRESS, assets);

        // Deposit  tokens to the Aave lending pool
        lendingPool.supply(address(asset), assets, address(this), 0);
    }

    /*//////////////////////////////////////////////////////////////
                            ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    function totalAssets() public view virtual override returns (uint256) {
        // aTokens use rebasing to accrue interest, so the total assets is just the aToken balance
        return asset.balanceOf(address(this));
    }
    

    function convertToShares(uint256 assets) public view virtual override returns (uint256) {
        uint256 supply = assets;
        return  supply;
    }

    function convertToAssets(uint256 shares) public view virtual override returns (uint256) {
        uint256 supply = shares;
        return  supply;
    }

    function previewDeposit(uint256 assets) public view virtual override returns (uint256) {
        return convertToShares(assets);
    }

    function previewMint(uint256 shares) public view virtual override returns (uint256) {
        uint256 supply = shares;
        return  supply;
    }

    function previewWithdraw(uint256 assets) public view virtual override returns (uint256) {
        uint256 supply = assets;
        return  supply;
    }

    function previewRedeem(uint256 shares) public view virtual override returns (uint256) {
        return convertToAssets(shares);
    }




   

    // function getPriceOracleAddress() public view returns (address) {

    //     PRICE_ORACLE = lendingPool.getPriceOracle();   
    //     return PRICE_ORACLE;

    // }

    // function getAssetPrice( ) public view  returns (uint256) {

    //     return priceOracle.getAssetPrice(USDC_ADDRESS);

    // }

    




    
}



// 
// address constant SUSHI_ADDRESS = 0x69d6444016CBE7f60f02A476B1832a36010c22e4;