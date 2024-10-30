// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

// Homework 5

// Implement a solidity contract that verifies the computation for the EC points.
// 0 = -A1.B2 + alpha1.beta2 + X1.gamma2 + C1.delta2
// where X1 = x1G1 + x2G1 + x3G1

// setting discrete-log values for the G1/G2 points above that satisfy the equation.
// we'll use this in tests as a passing case.
//
// ab = cd + ef+ gh
// 13 * 5 = (2 * 4) + (6 * 7) + (3 * 5)

contract PairingVerifier {
    struct G1Point {
        uint256 x;
        uint256 y;
    }

    struct G2Point {
        uint256[2] x;
        uint256[2] y;
    }

    uint256 constant CURVE_ORDER = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // G1 generator point for bn128
    G1Point G1 = G1Point(uint256(1), uint256(2));

    // alpha1 = 2 G1
    G1Point alpha1 = G1Point(
        uint256(1368015179489954701390400359078579693043519447331113978918064868415326638035),
        uint256(9918110051302171585080402603319702774565515993150576347155970296011118125764)
    );

    // beta2 = 4 G2
    G2Point beta2 = G2Point(
        [
            uint256(18936818173480011669507163011118288089468827259971823710084038754632518263340),
            uint256(18556147586753789634670778212244811446448229326945855846642767021074501673839)
        ],
        [
            uint256(18825831177813899069786213865729385895767511805925522466244528695074736584695),
            uint256(13775476761357503446238925910346030822904460488609979964814810757616608848118)
        ]
    );

    // gamma2 = 7 G2
    G2Point gamma2 = G2Point(
        [
            uint256(15512671280233143720612069991584289591749188907863576513414377951116606878472),
            uint256(18551411094430470096460536606940536822990217226529861227533666875800903099477)
        ],
        [
            uint256(13376798835316611669264291046140500151806347092962367781523498857425536295743),
            uint256(1711576522631428957817575436337311654689480489843856945284031697403898093784)
        ]
    );

    // delta2 = 5 G2
    G2Point delta2 = G2Point(
        [
            uint256(20954117799226682825035885491234530437475518021362091509513177301640194298072),
            uint256(4540444681147253467785307942530223364530218361853237193970751657229138047649)
        ],
        [
            uint256(21508930868448350162258892668132814424284302804699005394342512102884055673846),
            uint256(11631839690097995216017572651900167465857396346217730511548857041925508482915)
        ]
    );

    function verify(G1Point memory A1, G2Point memory B2, G1Point memory C1, uint256 x1, uint256 x2, uint256 x3)
        external
        view
        returns (bool)
    {
        // compute the G1 point X1
        G1Point memory X1;

        (X1.x, X1.y) = _multiplyPoints(G1.x, G1.y, (x1 + x2 + x3));

        return _pairing(_negate(A1), B2, alpha1, beta2, X1, gamma2, C1, delta2);
    }

    /// === internal functions ===

    function _pairing(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2,
        G1Point memory d1,
        G2Point memory d2
    ) internal view returns (bool) {
        G1Point[4] memory p1 = [a1, b1, c1, d1];
        G2Point[4] memory p2 = [a2, b2, c2, d2];

        // because each G1 point has 2 uint256 values, and G2 point has 4,
        // thus 6 for each pair above => 6 * 4 => 24
        uint256 inputSize = 24;

        uint256[] memory input = new uint256[](inputSize);

        for(uint256 i = 0; i < 4; i++) {
            uint256 j = i * 6;

            input[j + 0] = p1[i].x;
            input[j + 1] = p1[i].y;
            input[j + 2] = p2[i].x[0];
            input[j + 3] = p2[i].x[1];
            input[j + 4] = p2[i].y[0];
            input[j + 5] = p2[i].y[1];
        }

        uint256[1] memory out;
        // bool success;
        // bytes memory result;

        (bool success, bytes memory result) = address(8).staticcall(abi.encode(input));

        require(success, "pairing verification failed");

        out[0] = abi.decode(result, (uint256));

        return out[0] != 0;
    }

    function _multiplyPoints(uint256 x, uint256 y, uint256 s) internal view returns (uint256, uint256) {
        (bool ok, bytes memory data) = address(7).staticcall(abi.encode(x, y, s));
        require(ok, "multiplication failed");
        return abi.decode(data, (uint256, uint256));
    }

    function _negate(G1Point memory p) internal pure returns (G1Point memory) {
        if (p.x == 0 && p.y == 0) {
            return G1Point(0, 0);
        } else {
            return G1Point(p.x, PRIME_Q - (p.y % PRIME_Q));
        }
    }
}
