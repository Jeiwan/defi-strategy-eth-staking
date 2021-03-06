// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IBalancer, IERC20, IWETH, ILido, IAAVE} from "./interfaces.sol";

contract Strategy {
    error NotBalancer();
    error NotOwner();

    address constant aaveAddress = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;
    address constant balancerAddress =
        0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    address constant lidoAddress = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    address constant wethAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address private immutable owner;

    constructor() public {
        owner = msg.sender;
    }

    function go(address[] calldata tokens, uint256[] calldata amounts) public payable {
        if (msg.sender != owner) revert NotOwner();

        IBalancer(balancerAddress).flashLoan(
            address(this),
            tokens,
            amounts,
            ""
        );
    }

    function receiveFlashLoan(
        IERC20[] calldata tokens,
        uint256[] calldata amounts,
        uint256[] calldata feeAmounts,
        bytes calldata userData
    ) public payable {
        if (msg.sender != balancerAddress) revert NotBalancer();

        uint256 loanAmount = amounts[0];
        uint256 totalFunds = address(this).balance + loanAmount;

        // Unwrap WETH
        IWETH(wethAddress).withdraw(loanAmount);

        // Stake ETH
        ILido(lidoAddress).submit{value: totalFunds}(address(0x0));

        // Deposit stETH
        IERC20(lidoAddress).approve(aaveAddress, totalFunds);
        IAAVE(aaveAddress).deposit(lidoAddress, totalFunds, owner, 0);

        // Borrow ETH
        IAAVE(aaveAddress).borrow(wethAddress, loanAmount, 2, 0, owner);

        // Repay flash loan
        tokens[0].transfer(balancerAddress, loanAmount);
    }

    receive() external payable {}
}
