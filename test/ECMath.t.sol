// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ECMath} from "../src/ECMath.sol";

contract ECMathTest is Test {
    ECMath public ecmath;

    function setUp() public {
        ecmath = new ECMath();
    }

    function _ecPoint(uint256 num) internal returns (ECMath.ECPoint memory point) {
        string[] memory inputs = new string[](3);
        inputs[0] = "python3";
        inputs[1] = "test/py-scripts/ec_point.py";
        inputs[2] = vm.toString(num);

        bytes memory result = vm.ffi(inputs);
        string memory output = string(result);
        string[] memory coordStr = vm.split(output, ",");

        point.x = vm.parseUint(coordStr[0]);
        point.y = vm.parseUint(coordStr[1]);
    }

    function test_rationalAdd() public {
        uint256 num = 2;
        ECMath.ECPoint memory point = _ecPoint(num);

        ecmath.rationalAdd(point, point, 4, 1);
    }

    function test_matmul() public {}
}
