// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "ds-test/test.sol";
import {Strategy} from "../Strategy.sol";
import {IAAVE, IERC20, VariableDebtToken} from "../interfaces.sol";

contract StrategySimulationTest is DSTest {
    address constant aaveAddress = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;
    address constant variableDebtWethAddress =
        0xF63B34710400CAd3e044cFfDcAb00a0f32E33eCf;
    address constant wethAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    uint256 constant funds = 1 ether;
    uint256 constant flashLoanFunds = (funds * 230) / 100;

    Strategy s;

    function setUp() public {
        s = new Strategy();
    }

    function testGo() public {
        VariableDebtToken(variableDebtWethAddress).approveDelegation(
            address(s),
            3 ether
        );

        address[] memory tokens = new address[](1);
        tokens[0] = wethAddress;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = flashLoanFunds;

        s.go{value: 1 ether}(tokens, amounts);

        (
            uint256 totalCollateralETH,
            uint256 totalDebtETH,
            uint256 availableBorrowsETH,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        ) = IAAVE(aaveAddress).getUserAccountData(address(this));

        assertEq(
            totalCollateralETH,
            3.296866859883764637 ether,
            "invalid total collateral"
        );
        assertEq(totalDebtETH, 2.3 ether, "invalid total debt");
        assertEq(
            availableBorrowsETH,
            0.007806801918635246 ether,
            "invalid available borrows ETH"
        );
        assertEq(
            currentLiquidationThreshold,
            7500,
            "invalud current liquidation threshold"
        );
        assertEq(ltv, 7000, "invalid LTV");
        assertEq(
            healthFactor,
            1.075065280396879773 ether,
            "invalid health factor"
        );
    }
}
