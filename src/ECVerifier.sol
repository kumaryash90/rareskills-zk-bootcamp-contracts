// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/console.sol";

contract ECVerifier {
    struct G1Point {
        uint256 x;
        uint256 y;
    }

    struct G2Point {
        uint256[2] x;
        uint256[2] y;
    }

    uint256 constant CURVE_ORDER = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 constant MOD = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    G1Point alpha1;
    G2Point beta2;
    G2Point gamma2;
    G2Point delta2;

    G1Point G1 = G1Point(uint256(1), uint256(2));

    function verify(G1Point calldata A1, G2Point calldata B2, G1Point calldata C1, uint256 x1, uint256 x2, uint256 x3)
        public
        view
        returns (bool)
    {
        G1Point memory X1;
        (X1.x, X1.y) = _multiplyPoints(G1.x, G1.y, x1);
        (uint256 xTemp, uint256 yTemp) = _multiplyPoints(G1.x, G1.y, x2);
        (X1.x, X1.y) = _addPoints(X1.x, X1.y, xTemp, yTemp);
        (xTemp, yTemp) = _multiplyPoints(G1.x, G1.y, x3);
        (X1.x, X1.y) = _addPoints(X1.x, X1.y, xTemp, yTemp);

        
    }

    function _addPoints(uint256 x1, uint256 y1, uint256 x2, uint256 y2) internal view returns (uint256, uint256) {
        (bool ok, bytes memory data) = address(6).staticcall(abi.encode(x1, y1, x2, y2));
        require(ok, "addition failed");
        return abi.decode(data, (uint256, uint256));
    }

    function _multiplyPoints(uint256 x, uint256 y, uint256 s) internal view returns (uint256, uint256) {
        (bool ok, bytes memory data) = address(7).staticcall(abi.encode(x, y, s));
        require(ok, "multiplication failed");
        return abi.decode(data, (uint256, uint256));
    }
}
