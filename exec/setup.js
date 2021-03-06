const SolnPreimageVerifier = artifacts.require('SolnPreimageVerifier')

/* ---------------------------- Proofs and tokens --------------------------- */
const p1 = require('../proofs/proof_token_1.json')
const p2 = require('../proofs/proof_token_2.json')
const p3 = require('../proofs/proof_token_3.json')
const p4 = require('../proofs/proof_token_4.json')
const p5 = require('../proofs/proof_token_5.json')
const p6 = require('../proofs/proof_token_6.json')
const p7 = require('../proofs/proof_token_7.json')
const p8 = require('../proofs/proof_token_8.json')
const p9 = require('../proofs/proof_token_9.json')
const p10 = require('../proofs/proof_token_10.json')

const proofs = [p1, p2, p3, p4, p5, p6, p7, p8, p9, p10]
const tokens = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

/* ---------------------- Pretty printer for event logs --------------------- */
function printEvents(events) {
    for (let i = 0; i < events.length; i++) {
        let contents = events[i].args
        let name = events[i].event
        // Removing redundant entries 
        for (var key in contents) {
            if (!isNaN(key) || key.indexOf("_") == 0)
                delete contents[key];
        }

        console.log(`${name} event #${i + 1}\n${JSON.stringify(contents, null, 4)}`)
    }
}


module.exports = async function (callback) {
    try {
        const accounts = await web3.eth.getAccounts()
        const [owner, account] = accounts

        SolnPreimageVerifier.defaults({
            gas: 6000000,
        })

        const contract = await SolnPreimageVerifier.deployed()

        /* ------------ Checking if the deployed contract data is correct ----------- */
        let name = await contract.name.call();
        let symbol = await contract.symbol.call();
        console.log(contract.address, "Address");
        console.log(name, "Name");
        console.log(symbol, "Symbol");

        /* -------------------- Starting the verification process ------------------- */
        let i = 0;
        for (let p of proofs) {
            console.log(p.inputs, `Verifying proof #${i + 1}`)
            let token = tokens[i]
            await contract.verify(token, p.proof.a, p.proof.b, p.proof.c, p.inputs, { from: owner })
            i++
        }
        console.log(`Verified ${i} tokens`)

        /* ---------------------- Starting the minting process ---------------------- */
        i = 0;
        for (let p of proofs) {
            console.log(`Minting token #${tokens[i]}`)
            let token = tokens[i]
            await contract.mintVerified(owner, token, { from: owner })            
            i++
        }
        console.log(`Minted ${i} tokens`)

        /* -------------------- Starting the transfering process -------------------- */
        console.log(`Transfering token #${tokens[0]}`)

        let tokenOwner = await contract.ownerOf.call(tokens[0])
        console.log(tokenOwner, "Owner before")
        await contract.approve(account, tokens[0], { from: owner })
        await contract.transferFrom(owner, account, tokens[0], { from: owner })
        tokenOwner = await contract.ownerOf.call(tokens[0])
        console.log(tokenOwner, "Owner after")

        console.log(`Transferef token ${tokens[0]}`)

        let tokenURI = await contract.tokenURI.call(tokens[0]);
        console.log(tokenURI, "Token 1 URI");

        /* --------------------------- Checking the events -------------------------- */
        let logs = await contract.getPastEvents('allEvents', { fromBlock: 0, toBlock: 'latest' })
        printEvents(logs)

    }
    catch (error) {
        console.log(error)
    }

    callback()
}