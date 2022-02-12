# NFHousing
## Udacity Blockchain Nanodegree Capstone Project

Decentralized housing project leveraging zkSNARKs and ERC-721 standard. 

### Stack

- Truffle
- Ganache
- Web3
- Open Zeppelin
- ZoKrates
- Docker
- Node JS

### Installation

1. First of all execute `npm install` in order to install all the necessary packages
2. Make sure you have Truffle Suite installed. See [this link](https://trufflesuite.com/docs/truffle/getting-started/installation)
3. Make sure you have Ganache CLI installed. See [this link](https://github.com/trufflesuite/ganache/)
4. Launch `ganache-cli` or execute `sh run-ganache.sh`
5. Rename **secret-sample.json** into **secret.json** and fill the blanks with
   - a couple of private keys for your Ethereum accounts on Rinkeby (do not push or share the keys online)
   - your Infura API key
6. Execute `npm run compile` in order to run the compilation scripts
7. Execute `npm run test` in order to test the contracts with some Mocha scripts
8. With `npm run migrate` script you can deploy the contracts to Ganache
9. The setup script `npm run setup` automates the verification and minting process for 10 tokens 
10. In order to execute the same operation on testnet use \
`npm run migrate-testnet` and `npm run setup-testnet`

### Zokrates

This project provides a Verifier.sol contract and a set of premade ZK proof files inside the **proofs** folder. \
In order to generate more custom proofs you'll need to run [ZoKrates](https://github.com/Zokrates/ZoKrates) on your local machine, \
If you don't have Docker installed, check [this link](https://docs.docker.com/install).

1. Put the path to the project folder in the following command and run it in a new terminal window \
`docker run -v "<path_to_project>/zokrates/code":/home/zokrates/code -ti zokrates/zokrates //bin/bash` 
2. In the Docker CLI, move to the folder **proof** `cd /home/zokrates/code/proof`
3. Compile the source file with `zokrates compile -i preimage.code`
4. Initialize the verification pipeline with `zokrates setup`
5. The command `zokrates export-verifier` exports a Solidity file you can rename and move to your **contracts** \
folder in order to inherit the verification algorythm inside your own verification contract
6. Compute a witness by providing the expected input values `zokrates compute-witness -a ...` \
In this particular project the zero knowledge is obtained through a \
[SHA256 preimage](https://zokrates.github.io/examples/sha256example.html) so the function expects 4 inputs, for example \
`zokrates compute-witness -a 0 0 0 1`
7. Once the witness is created, use `zokrates generate-proof` to generate a json file for ZK verification
8. Steps **5** and **6** have to be repeated for each single token, so you should store the proof.json \
file with a unique name 

### OpenSea

[NFHousing Token Collection](https://testnets.opensea.io/collection/nfhousing-v2)

__DISCLAIMER: I do not own the collection logo or the header image, \
I've used some free pictures available on freepick.com and unsplash.com__

### Etherscan

Contract on Rinkeby [0x005d9cB551aFB88f53Da6d305fF4dDB2fF1E5f66](https://rinkeby.etherscan.io/address/0x005d9cB551aFB88f53Da6d305fF4dDB2fF1E5f66) \
[Token transactions](https://rinkeby.etherscan.io/address/0x783a6977da09f147061acac6aa3554f771080e09#tokentxnsErc721) \
[Token sold](https://rinkeby.etherscan.io/tx/0x5fb658df88ee6282a79976826f37c4b476a338da88f4dd744a87758ec416e301) on OpenSea 


