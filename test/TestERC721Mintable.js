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

    NFHousingToken.defaults({
        gas: 6000000,
        gasPrice: '2000000'
    })


    describe('match erc721 spec', function () {
        beforeEach(async function () {

            this.contract = await NFHousingToken.new(name, symbol, { from: owner })

            // + TODO: mint multiple tokens
            result = await this.contract.mint(account_one, tokens[0], { from: owner })
            result.logs.length.should.equal(1, "No events have been emitted")
            result = await this.contract.mint(account_two, tokens[1], { from: owner })
            result.logs.length.should.equal(1, "No events have been emitted")
            result = await this.contract.mint(account_one, tokens[2], { from: owner })
            result.logs.length.should.equal(1, "No events have been emitted")
        })

        it('should return total supply', async function () {
            let totalSupply = await this.contract.totalSupply.call()
            totalSupply = getNumber(totalSupply)
            totalSupply.should.equal(3, "The total supply doesn't match the expected value")

        })
        /*
                it('should get token balance', async function () {
        
                })
        
                // token uri should be complete i.e: https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/1
                it('should return token uri', async function () {
        
                })
        
                it('should transfer token from one owner to another', async function () {
        
                })
                */
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