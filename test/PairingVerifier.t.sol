// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {PairingVerifier} from "../src/PairingVerifier.sol";

contract PairingVerifierTest is Test {
    PairingVerifier public pairingVerifier;

    PairingVerifier.G1Point A1;
    PairingVerifier.G2Point B2;
    PairingVerifier.G1Point C1;

    uint256 x1;
    uint256 x2;
    uint256 x3;

    function setUp() public {
        pairingVerifier = new PairingVerifier();

        // A1 = 13 G1
        A1.x = 2672242651313367459976336264061690128665099451055893690004467838496751824703;
        A1.y = 18247534626997477790812670345925575171672701304065784723769023620148097699216;

        // B2 = 5 G2
        B2.x[0] = 20954117799226682825035885491234530437475518021362091509513177301640194298072;
        B2.x[1] = 4540444681147253467785307942530223364530218361853237193970751657229138047649;
        B2.y[0] = 21508930868448350162258892668132814424284302804699005394342512102884055673846;
        B2.y[1] = 11631839690097995216017572651900167465857396346217730511548857041925508482915;

        // C1 = 3 G1
        C1.x = 3353031288059533942658390886683067124040920775575537747144343083137631628272;
        C1.y = 19321533766552368860946552437480515441416830039777911637913418824951667761761;

        x1 = 1;
        x2 = 2;
        x3 = 3;
    }

    function _multiplyPoints(uint256 x, uint256 y, uint256 s) internal view returns (uint256, uint256) {
        (bool ok, bytes memory data) = address(7).staticcall(abi.encode(x, y, s));
        require(ok, "multiplication failed");
        return abi.decode(data, (uint256, uint256));
    }

    function test_verify() public view {
        bool success = pairingVerifier.verify(A1, B2, C1, x1, x2, x3);

        assertTrue(success);
    }

    function test_fail_verify_invalidValues() public {
        x1 = 10; // invalid value

        bool success = pairingVerifier.verify(A1, B2, C1, x1, x2, x3);

        vm.assertFalse(success);
    }
}
