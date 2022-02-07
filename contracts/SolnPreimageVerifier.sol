// SPDX-License-Identifier: MIT
pragma solidity >=0.8.11;

import "./NFHousing.sol";
import "./Verifier.sol";

// ??? TODO define a contract call to the zokrates generated solidity contract <Verifier> or <renamedVerifier>

// + TODO define another contract named SolnSquareVerifier that inherits from your ERC721Mintable class

contract SolnPreimageVerifier is NFHousingToken {
    PreimageVerifier verifier;
    // + TODO define a solutions struct that can hold an index & an address
    // + TODO define an array of the above struct
    // + TODO define a mapping to store unique solutions submitted
    // + TODO Create an event to emit when a solution is added
    // + TODO Create a function to add the solutions to the array and emit the event
    // + TODO Create a function to mint new NFT only after the solution has been verified
    //  - make sure the solution is unique (has not been used before)
    //  - make sure you handle metadata as well as tokenSuplly

    mapping(bytes32 => Solution) internal solutions;
    mapping(bytes32 => bool) internal solutionsSubmitted;
    mapping(uint256 => bytes32) internal solutionsPerToken;

    constructor(address payable verAddress) NFHousingToken("NFHousing", "NFH") {
        verifier = PreimageVerifier(verAddress);
    }

    struct Solution {
        uint256[2] a;
        uint256[2][2] b;
        uint256[2] c;
        uint256[2] i;
    }

    event SolutionAdded(
        uint256 indexed token,
        bytes32 indexed key,
        address indexed account,
        uint256 timestamp
    );

    function addSolution(
        uint256 token,
        uint256[2] calldata a,
        uint256[2][2] calldata b,
        uint256[2] calldata c,
        uint256[2] calldata i
    ) external {
        bytes32 key = keccak256(abi.encodePacked(a, b, c, i));
        Solution memory s = Solution(a, b, c, i);
        solutions[key] = s;
        solutionsSubmitted[key] = true;
        solutionsPerToken[token] = key;
        emit SolutionAdded(token, key, msg.sender, block.timestamp);
    }

    function mintVerified(address to, uint256 token)
        external
        returns (bool minted)
    {
        require(solutionsPerToken[token].length != 0, "Token proof required");
        return super.mint(to, token);
    }
}

contract PreimageVerifier is Verifier {
    function verify(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[2] memory input
    ) public view returns (bool) {
        return
            super.verifyTx(
                Proof(
                    Pairing.G1Point(a[0], a[1]),
                    Pairing.G2Point(b[0], b[1]),
                    Pairing.G1Point(c[0], c[1])
                ),
                input
            );
    }
}
