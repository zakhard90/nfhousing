// + Test if a new solution can be added for contract - SolnSquareVerifier

// + Test if an ERC721 token can be minted for contract - SolnSquareVerifier

const PreimageVerifier = artifacts.require('PreimageVerifier')
const SolnPreimageVerifier = artifacts.require('SolnPreimageVerifier')
const p1 = require('../proofs/proof_token_1.json')
const p2 = require('../proofs/proof_token_2.json')
const p3 = require('../proofs/proof_token_3.json')
const p4 = require('../proofs/proof_token_4.json')
const p5 = require('../proofs/proof_token_5.json')

const proofs = [p1, p2, p3, p4, p5]
const tokens = [1, 2, 3, 4, 5]

require('chai').use(require('chai-as-promised')).should()

const getNumber = (bigNumber) => {
    return Number(bigNumber.toString())
}

contract('SolnPreimageVerifier', accounts => {

    const [owner, account_one, account_two] = accounts
    let result

    SolnPreimageVerifier.defaults({
        gas: 6000000,
        gasPrice: '2000000'
    })


    describe('verification and minting', function () {
        before(async function () {
            const verifier = await PreimageVerifier.new({ from: owner })
            this.contract = await SolnPreimageVerifier.new(verifier.address, { from: owner })
        })

        it('should verify proof and add a solution correctly', async function () {
            let i = 0;
            for (let p of proofs) {
                let account = i < 3 ? account_one : account_two
                let token = tokens[i]
                await this.contract.verify(token, p.proof.a, p.proof.b, p.proof.c, p.inputs, { from: account })
                result = await this.contract.checkSolutionProvider.call(token)
                result.should.equal(account, 'The solution provider does not match')
                i++
            }
        })

        it('should mint tokens correctly', async function () {
            for (let i in tokens) {
                let account = i < 3 ? account_one : account_two
                let token = tokens[i]
                await this.contract.mintVerified(account, token, { from: owner })
            }
            let balance = await this.contract.balanceOf.call(account_one)
            balance = getNumber(balance)
            balance.should.equal(3, "The balance doesn't match the expected value")
            balance = await this.contract.balanceOf.call(account_two)
            balance = getNumber(balance)
            balance.should.equal(2, "The balance doesn't match the expected value")
        })

    })
})