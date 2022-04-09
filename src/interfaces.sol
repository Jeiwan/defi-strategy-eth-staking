// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

interface IBalancer {
    function flashLoan(
        address recipient,
        address[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external;
}

interface IERC20 {
    function approve(address, uint256) external;

    function balanceOf(address) external returns (uint256);

    function transfer(address, uint256) external;
}

interface IWETH {
    function deposit(uint256) external;

    function withdraw(uint256) external;
}

interface ILido {
    function submit(address) external payable;
}

interface IAAVE {
    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function getUserAccountData(address)
        external
        returns (
            uint256 totalCollateralETH,
            uint256 totalDebtETH,
            uint256 availableBorrowsETH,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        );
}

interface VariableDebtToken {
    function approveDelegation(address delegatee, uint256 amount) external;
}
