// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleDistributor {
    ERC20 public token;

    bytes32 public merkleRoot;

    // mapping from address to token amount claimed
    mapping(address => uint256) public claimed;

    constructor(ERC20 _token, bytes32 _merkleRoot) {
        token = _token;
        merkleRoot = _merkleRoot;
    }

    function claim(
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
        // verify the merkle proof
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(
            MerkleProof.verify(merkleProof, merkleRoot, node),
            "Invalid proof"
        );

        // mark it claimed
        claimed[account] = amount;

        // transfer tokens
        require(token.transfer(account, amount), "Transfer failed");
    }

    // script to add enabled addresses
    function addEnabledAddresses(
        address[] memory accounts,
        uint256[] memory amounts
    ) public {
        for (uint i = 0; i < accounts.length; i++) {
            claimed[accounts[i]] = amounts[i];
        }
    }
}
