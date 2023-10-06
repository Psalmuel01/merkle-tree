//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleRootGenerator {
    function generateMerkleRoot(
        address[] memory addresses,
        uint256[] memory amounts
    ) public pure returns (bytes32) {
        require(
            addresses.length == amounts.length,
            "Arrays must have the same length"
        );

        bytes32[] memory nodes = new bytes32[](addresses.length);
        for (uint256 i = 0; i < addresses.length; i++) {
            nodes[i] = keccak256(abi.encodePacked(addresses[i], amounts[i]));
        }

        bytes32 merkleRoot = generateMerkleRootFromNodes(nodes);
        return merkleRoot;
    }

    function generateMerkleProofs(
        address[] memory addresses,
        uint256[] memory amounts,
        uint256 index
    ) public pure returns (bytes32[] memory) {
        require(
            addresses.length == amounts.length,
            "Arrays must have the same length"
        );
        require(index < addresses.length, "Invalid index");

        bytes32[] memory leaves = new bytes32[](addresses.length);
        for (uint256 i = 0; i < addresses.length; i++) {
            leaves[i] = keccak256(abi.encodePacked(addresses[i], amounts[i]));
        }

        bytes32[] memory merkleProof = generateMerkleProofsFromLeafNodes(
            leaves,
            index
        );
        return merkleProof;
    }

    function generateMerkleRootFromNodes(
        bytes32[] memory nodes
    ) public pure returns (bytes32) {
        require(nodes.length > 0, "Nodes array must not be empty");

        while (nodes.length > 1) {
            if (nodes.length % 2 != 0) {
                bytes32[] memory newNodes = new bytes32[](nodes.length + 1);
                for (uint256 i = 0; i < nodes.length; i++) {
                    newNodes[i] = nodes[i];
                }
                newNodes[nodes.length] = nodes[nodes.length - 1];
                nodes = newNodes;
            }

            bytes32[] memory parentNodes = new bytes32[](nodes.length / 2);
            for (uint256 i = 0; i < nodes.length; i += 2) {
                parentNodes[i / 2] = keccak256(
                    abi.encodePacked(nodes[i], nodes[i + 1])
                );
            }

            nodes = parentNodes;
        }

        return nodes[0];
    }

    function generateMerkleProofsFromLeafNodes(
        bytes32[] memory leafNodes,
        uint256 index
    ) public pure returns (bytes32[] memory) {
        require(leafNodes.length > 0, "Leaf nodes array must not be empty");
        require(
            index < leafNodes.length,
            "Index must be less than the length of the leaf nodes array"
        );

        bytes32[] memory nodes = new bytes32[](leafNodes.length);
        for (uint256 i = 0; i < leafNodes.length; i++) {
            nodes[i] = leafNodes[i];
        }

        bytes32[] memory proof = new bytes32[](leafNodes.length - 1);
        uint256 j = 0;

        while (nodes.length > 1) {
            if (index % 2 == 1) {
                proof[j] = nodes[index - 1];
            } else {
                proof[j] = nodes[index + 1];
            }
            j++;

            index = (index + 1) / 2;

            bytes32[] memory parentNodes = new bytes32[](nodes.length / 2);
            for (uint256 i = 0; i < parentNodes.length; i++) {
                parentNodes[i] = keccak256(
                    abi.encodePacked(nodes[i * 2], nodes[i * 2 + 1])
                );
            }

            nodes = parentNodes;
        }

        return proof;
    }
}
