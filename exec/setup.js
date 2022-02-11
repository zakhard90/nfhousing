const SolnPreimageVerifier = artifacts.require('SolnPreimageVerifier')

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

module.exports = async function (callback) {
    try {
        const accounts = await web3.eth.getAccounts()
        const [owner, account] = accounts

        SolnPreimageVerifier.defaults({
            gas: 6000000,
            gasPrice: '2000000'
        })

        const contract = await SolnPreimageVerifier.deployed()

        let i = 0;
        for (let p of proofs) {
            console.log(p.inputs, `Verifying proof #${i+1}`)
            let token = tokens[i]
            await contract.verify(token, p.proof.a, p.proof.b, p.proof.c, p.inputs, { from: account })
            await contract.mintVerified(account, token, { from: owner })            
            i++
        }
        console.log(`Minted ${i} tokens`)
    }
    catch (error) {
        console.log(error)
    }

    callback()
}