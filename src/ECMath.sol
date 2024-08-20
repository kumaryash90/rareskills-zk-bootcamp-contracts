// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/console.sol";

contract ECMath {
    struct ECPoint {
        uint256 x;
        uint256 y;
    }

    uint256 constant CURVE_ORDER = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 constant gx = 1; 
    uint256 constant gy = 2; 

    function rationalAdd(ECPoint calldata A, ECPoint calldata B, uint256 num, uint256 den)
        public
        view
        returns (bool verified)
    {
        // ==== 1. compute the fraction num / den ======

        bytes memory input = abi.encodePacked(
            uint256(32), // length of the base
            uint256(32), // length of the exponent
            uint256(32), // length of the modulus
            den,
            CURVE_ORDER - 2,
            CURVE_ORDER
        );

        // staticcall to address(5) for modExp
        (bool success, bytes memory output) = address(5).staticcall(input);
        uint256 denInv = abi.decode(output, (uint256));

        // use mulmod to get num * denInv
        uint256 f = mulmod(num, denInv, CURVE_ORDER);

        // ==== 2. scalar multiply generator point with the fraction result ======
        ECPoint memory fG;
        (fG.x, fG.y) = _multiplyPoints(gx, gy, f);

        // ==== 3. add the points A and B using precompile 0x6
        ECPoint memory C;
        (C.x, C.y) = _addPoints(A.x, A.y, B.x, B.y);

        // ==== 4. check equality A + B == pointFraction
        verified = C.x == fG.x && C.y == fG.y;
    }

    function matmul(
        uint256[] calldata matrix,
        uint256 n, // n x n for the matrix
        ECPoint[] calldata s, // n elements
        uint256[] calldata o
    ) public returns (bool verified) {
        // revert if dimensions don't make sense or the matrices are empty
        require(n != 0 && matrix.length == n * n, "Invalid dimensions");
        require(s.length == n, "Invalid dimensions");
        require(o.length == n, "Invalid dimensions");

        // return true if Ms == o elementwise. You need to do n equality checks. If you're lazy, you can hardcode n to 3, but it is suggested that you do this with a for loop
        ECPoint[] memory product = new ECPoint[](n);
        for (uint256 i = 0; i < matrix.length; i++) {
            product[i] = _computeRowSum(matrix, s, n, i);
        }

        ECPoint[] memory oG = new ECPoint[](n);
        verified = true;
        for (uint256 i = 0; i < o.length; i++) {
            (oG[i].x, oG[i].y) = _multiplyPoints(gx, gy, o[i]);

            if (oG[i].x != product[i].x || oG[i].y != product[i].y) {
                verified = false;
                break;
            }
        }
    }

    function _computeRowSum(uint256[] calldata matrix, ECPoint[] calldata s, uint256 n, uint256 i)
        internal
        view
        returns (ECPoint memory sum)
    {
        for (uint256 j = 0; j < n; j++) {
            (uint256 x, uint256 y) = _multiplyPoints(s[j].x, s[j].y, matrix[i * n + j]);

            (x, y) = _addPoints(sum.x, sum.y, x, y);

            sum.x = x;
            sum.y = y;
        }
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
