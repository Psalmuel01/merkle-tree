// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../src/MerkleDistributor.sol";

contract MerkleDistributorTest is Test {
    MerkleDistributor distributor;
    ERC20 token; 

    function setUp() public {
        token = new ERC20("Test", "TST");
        bytes32 merkleRoot = 0x123...; // mock merkle root

        distributor = new MerkleDistributor(token, merkleRoot);
    }

    function testClaim() public {
        uint256 index = 0;
        address account = address(1);
        uint256 amount = 100;
        bytes32[] memory proof = new bytes32[](4); // mock proof

        vm.startPrank(account);
        distributor.claim(index, account, amount, proof);
        vm.stopPrank();

        assertEq(token.balanceOf(account), amount);
        assertEq(distributor.claimed(account), amount);
    }

    function testMultipleClaims() public {
        // make multiple claims
        distributor.claim(0, address(1), 100, new bytes32[](4)); 
        distributor.claim(1, address(2), 200, new bytes32[](4));

        // check claimed amounts
        assertEq(distributor.claimed(address(1)), 100);
        assertEq(distributor.claimed(address(2)), 200);
    }

    function testInvalidProof() public {
        vm.expectRevert("Invalid proof");
        distributor.claim(0, address(1), 100, new bytes32[](4));
    }

    function testAddEnabledAddresses() public {
        address[] memory accounts = new address[](2);
        accounts[0] = address(1);
        accounts[1] = address(2);

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 100;
        amounts[1] = 200;

        distributor.addEnabledAddresses(accounts, amounts);

        assertEq(distributor.claimed(address(1)), 100);
        assertEq(distributor.claimed(address(2)), 200);
    }
}