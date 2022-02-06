const Web3 = require('web3')
const NFHousingToken = artifacts.require('NFHousingToken')

require('chai').use(require('chai-as-promised')).should()

const getNumber = (bigNumber) => {
    return Number(bigNumber.toString())
}

contract('NFHousing', accounts => {

    const [owner, account_one, account_two] = accounts
    const tokens = [1, 2, 3, 4, 5]
    let result

    const name = "NFHouse"
    const symbol = "NFH"
    const baseUri = "https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/"

    NFHousingToken.defaults({
        gas: 6000000,
        gasPrice: '2000000'
    })


    describe('match erc721 spec', function () {
        beforeEach(async function () {

            this.contract = await NFHousingToken.new(name, symbol, { from: owner })

            // + TODO: mint multiple tokens
            for (let token of tokens) {
                result = await this.contract.mint(token < 3 ? account_one : account_two, token, { from: owner })
                result.logs.length.should.equal(1, "No events have been emitted")
            }
        })

        it('should return total supply', async function () {
            let totalSupply = await this.contract.totalSupply.call()
            totalSupply = getNumber(totalSupply)
            totalSupply.should.equal(tokens.length, "The total supply doesn't match the expected value")

        })
        it('should get token balance', async function () {
            let balance = await this.contract.balanceOf.call(account_one)
            balance = getNumber(balance)
            balance.should.equal(2, "The balance doesn't match the expected value")
        })

        // token uri should be complete i.e: https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/1
        it('should return token uri', async function () {
            let uri = await this.contract.getTokenURI.call(tokens[1])
            uri.should.equal(baseUri + tokens[1],"The token URI is incorrect")
        })

        it('should transfer token from one owner to another', async function () {

        })
    });
    /*
        describe('have ownership properties', function () {
            beforeEach(async function () {
                this.contract = await ERC721MintableComplete.new({ from: owner });
            })
    
            it('should fail when minting when address is not contract owner', async function () {
    
            })
    
            it('should return contract owner', async function () {
    
            })
    
        });
        */
})