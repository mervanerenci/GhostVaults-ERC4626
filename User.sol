// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {IERC20} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import {IERC4626} from "./interfaces/IERC4626.sol";
import {IBatcher} from "./interfaces/IBatcher.sol";

/**
 * @title User Contract
 * @dev Contract for managing user interactions and transactions.
 */
contract User {
    address public _user;
    address public vaultAddress;
    address constant USDC_ADDRESS = 0xe9DcE89B076BA6107Bb64EF30678efec11939234;
    address constant BATCHER_ADDRESS = 0x60CDEF31A8F7A179C7C564A34EE55C00D431A2ff;

    IERC20 public USDC;
    IERC4626 public vault;
    IBatcher public batcher;
     
    constructor() {
        _user = msg.sender;
        batcher = IBatcher(BATCHER_ADDRESS);
        USDC = IERC20(USDC_ADDRESS);
    }

    /**
     * @dev Modifier to check if the caller is the user.
     */
    modifier onlyUser() {
        require(msg.sender == _user, "Not a valid user");
        _;
    }

    /**
     * @dev Deposit USDC tokens into the vault.
     * @param amount The amount of USDC tokens to deposit.
     */
    function depositUSDC(uint256 amount) public onlyUser {
        USDC.approve(address(vault), amount);
        vault.deposit(amount, address(this)); 
    }

    /**
     * @dev Set a new vault address.
     * @param _vaultAddress The address of the new vault.
     */
    function setVault(address _vaultAddress) public onlyUser {
        vaultAddress = _vaultAddress;
        vault = IERC4626(_vaultAddress);
    }

    /**
     * @dev Withdraw USDC tokens from the vault.
     * @param amount The amount of USDC tokens to withdraw.
     */
    function withdrawUSDC(uint256 amount) public onlyUser {
        vault.withdraw(amount, address(this), address(this));
    }

    /**
     * @dev Send tokens to multiple recipients using a batcher contract.
     * @param _token The address of the token to send.
     * @param _recipients The addresses of the recipients.
     * @param _amounts The amounts of tokens to send to each recipient.
     */
    function sendToMultipleRecipients(
        address _token,
        address[] calldata _recipients,
        uint256[] calldata _amounts
    ) external {
        IERC20 token = IERC20(_token);
    uint256 totalAmount = 0;

    for (uint256 i = 0; i < _recipients.length; i++) {
        totalAmount += _amounts[i];
    }

    token.approve(address(batcher), totalAmount);
    batcher.sendToMultipleRecipients(_token, _recipients, _amounts);

    }

    
    
    receive() external payable {
        // Handle token transfers here
        // You can perform additional logic if needed
    }
}