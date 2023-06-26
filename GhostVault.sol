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

contract GhostVault is ERC4626{

    address constant USDC_ADDRESS = 0xe9DcE89B076BA6107Bb64EF30678efec11939234;
    address private constant POOL_ADDRESS_PROVIDER = 0xeb7A892BB04A8f836bDEeBbf60897A7Af1Bf5d7F;
    address private AAVE_LENDING_POOL_ADDRESS; 
    address private constant PRICE_ORACLE;
    
    // mapping for users to track their deposited balances
    mapping(address => uint256) public balances;
    
    IERC20 public USDC = IERC20(USDC_ADDRESS);
    IPool private lendingPool;
    IPriceOracle private priceOracle;

    ERC20 public immutable asset;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /*//////////////////////////////////////////////////////////////
                               IMMUTABLE
    //////////////////////////////////////////////////////////////*/

    ERC20 public immutable asset;


    constructor(
        ERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol, _asset.decimals()) {
        asset = _asset;

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
        asset.safeTransferFrom(msg.sender, address(this), assets);

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);

        afterDeposit(assets, shares);
    }

    function afterDeposit(uint256 assets, uint256 /*shares*/) internal virtual {
        // balances[msg.sender] += assets;
        // Get  balance
        uint256 userBalance = asset.balanceOf(msg.sender);
        // Ensure the user has enough balance to deposit
        require(userBalance >= amount, "Insufficient USDC balance"); 
        // Transfer  tokens to this smart contract
        require(asset.transferFrom(msg.sender, address(this), amount), "USDC transfer failed");

        // Approve lending pool to use  tokens from this smart contract
        require(asset.approve(AAVE_LENDING_POOL_ADDRESS, amount), "Approval failed");

        // Deposit  tokens to the Aave lending pool
        lendingPool.supply(asset, amount, address(this), 0);
    }




    // INTERNAL HOOKS //

    function getPriceOracleAddress() public view returns (address) {

        PRICE_ORACLE = lendingPool.getPriceOracle();   
        return PRICE_ORACLE;

    }

    function getAssetPrice( ) public view  returns (uint256) {

        return priceOracle.getAssetPrice(USDC_ADDRESS);

    }




    
}



// 
// address constant SUSHI_ADDRESS = 0x69d6444016CBE7f60f02A476B1832a36010c22e4;