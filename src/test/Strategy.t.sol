// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "ds-test/test.sol";
import {Strategy} from "../Strategy.sol";
import {IAAVE, IERC20, VariableDebtToken} from "../interfaces.sol";

contract StrategyTest is DSTest {
    address constant aaveAddress = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;
    address constant variableDebtWethAddress =
        0xF63B34710400CAd3e044cFfDcAb00a0f32E33eCf;

    Strategy s;

    function setUp() public {
        s = new Strategy();
    }

    function testGo() public {
        VariableDebtToken(variableDebtWethAddress).approveDelegation(
            address(s),
            3 ether
        );

        s.go{value: 1 ether}();

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
            3.298112774422300227 ether,
            "invalid total collateral"
        );
        assertEq(totalDebtETH, 2.3 ether, "invalid total debt");
        assertEq(
            availableBorrowsETH,
            0.008678942095610159 ether,
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
            1.07547155687683703 ether,
            "invalid health factor"
        );
    }
}
