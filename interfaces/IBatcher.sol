// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

interface Batcher {
    event BatchTransfer(
        address indexed token,
        address indexed sender,
        address[] recipients,
        uint256[] amounts
    );

    function sendToMultipleRecipients(
        address _token,
        address[] calldata _recipients,
        uint256[] calldata _amounts
    ) external;

    function batchTransferFrom(
        address _token,
        address[] calldata _senders,
        address[] calldata _recipients,
        uint256[] calldata _amounts
    ) external;
}
