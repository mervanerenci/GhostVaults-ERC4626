// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

// #Tasks
// Turn Nest contract to ERC4626 compliant
// 1-1 lP token distrubution

import {IPool} from "https://github.com/aave/aave-v3-core/blob/master/contracts/interfaces/IPool.sol";
import {IPoolAddressesProvider} from "https://github.com/aave/aave-v3-core/blob/master/contracts/interfaces/IPoolAddressesProvider.sol";
import {IPriceOracle} from "https://github.com/aave/aave-v3-core/blob/master/contracts/interfaces/IPriceOracle.sol";
import {IERC4626} from "./interfaces/IERC4626.sol";

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

contract User {

    address vaultAddress;
    address public _user;    
    address constant USDC_ADDRESS = 0xe9DcE89B076BA6107Bb64EF30678efec11939234;
    
    IERC20 public USDC = IERC20(USDC_ADDRESS);
    IERC4626 public vault;
     
    constructor(address _vaultAddress) {
        _user = msg.sender;
        
        vaultAddress = _vaultAddress;
        vault = IERC4626(vaultAddress);
    }

    modifier onlyUser() {
        require(msg.sender == _user, "Not valid user");
        
        _;
    }

    function depositUSDC(uint256 amount) public onlyUser {

        USDC.approve(address(vault) ,amount);
        vault.deposit(amount, _user); 
    }
 

}