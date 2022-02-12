// SPDX-License-Identifier: MIT
pragma solidity >=0.8.11;

import "../node_modules/@openzeppelin/contracts/utils/Address.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./Oraclize.sol";

contract Ownable {

    address private _contractOwner;

    constructor() {
        _contractOwner = msg.sender;
        emit OwnershipTransfered(_contractOwner, block.timestamp);
    }

    modifier onlyContractOwner() {
        require(
            msg.sender == _contractOwner,
            "The sender is not the contract owner"
        );
        _;
    }

    function contractOwner() external view returns (address) {
        return _contractOwner;
    }

    function isContractOwner() internal view returns (bool) {
        return (msg.sender == _contractOwner);
    }

    event OwnershipTransfered(
        address indexed newContractOwner,
        uint256 timestamp
    );

    function transferOwnership(address newContractOwner)
        external
        onlyContractOwner
    {
        require(newContractOwner != address(0), "Proposed address is null");
        require(
            newContractOwner != _contractOwner,
            "Proposed address is already the owner"
        );
        _contractOwner = newContractOwner;
        emit OwnershipTransfered(_contractOwner, block.timestamp);
    }
}

contract Utils {
    modifier isValidAddress(address checkAddress) {
        require(checkAddress != address(0), "Invalid address");
        _;
    }
}

contract Pausable is Ownable {
    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier paused() {
        require(_paused, "Contract is not paused");
        _;
    }

    modifier whenNotPaused() {
        require(!_paused, "Contract is paused");
        _;
    }

    event Paused(address indexed operator, uint256 timestamp);
    event Unpaused(address indexed operator, uint256 timestamp);

    function setPaused(bool mode) public onlyContractOwner {
        require(mode != _paused, "Pause status has to be different");
        _paused = mode;
        if (_paused) {
            emit Paused(msg.sender, block.timestamp);
        } else {
            emit Unpaused(msg.sender, block.timestamp);
        }
    }
}

contract ERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    /*
     * 0x01ffc9a7 ===
     *     bytes4(keccak256('supportsInterface(bytes4)'))
     */

    /**
     * @dev a mapping of interface id to whether or not it's supported
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    /**
     * @dev A contract implementing SupportsInterfaceWithLookup
     * implement ERC165 itself
     */
    constructor() {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev implement supportsInterface(bytes4) using a lookup table
     */
    function supportsInterface(bytes4 interfaceId)
        external
        view
        returns (bool)
    {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev internal method for registering an interface
     */
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "Invalid interfaceId");
        _supportedInterfaces[interfaceId] = true;
    }
}

contract ERC721 is Pausable, Utils, ERC165 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool _approved
    );

    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping(uint256 => address) private _tokenOwner;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => Counters.Counter) internal _ownedTokensCount;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor() {
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _ownedTokensCount[owner].current();
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        return _tokenOwner[tokenId];
    }

    //    @dev Approves another address to transfer the given token ID
    function approve(address to, uint256 tokenId) public {
        // NOTE cannot be owner of the contract but owner of the token
        address owner = ownerOf(tokenId);
        require(owner != to, "The requested address already owns the token");
        require(
            owner == msg.sender || isApprovedForAll(owner, msg.sender),
            "The approval is not possible for the sender"
        );
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf
     * @param to operator address to set the approval
     * @param approved representing the status of the approval to be set
     */
    function setApprovalForAll(address to, bool approved) public {
        require(to != msg.sender, "Cannot approve for the same address");
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    /**
     * @dev Tells whether an operator is approved by a given owner
     * @param owner owner address which you want to query the approval of
     * @param operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "Transfer not authorized"
        );

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public payable {
        transferFrom(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, data),
            "Token hasn't been received"
        );
    }

    /**
     * @dev Returns whether the specified token exists
     * @param tokenId uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return owner != address(0);
    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     * is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        returns (bool)
    {
        address owner = _tokenOwner[tokenId];
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    // @dev Internal function to mint a new token
    function _mint(address to, uint256 tokenId) internal isValidAddress(to) {
        require(ownerOf(tokenId) == address(0), "Token already minted");
        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();
        emit Transfer(address(0), to, tokenId);
    }

    // @dev Internal function to transfer ownership of a given token ID to another address.
    function _transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) internal isValidAddress(from) isValidAddress(to) {
        require(ownerOf(tokenId) == from, "Token owned by another address");

        delete _tokenApprovals[tokenId];
        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();
        _ownedTokensCount[from].decrement();

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Internal function to invoke `onERC721Received` on a target address
     * The call is not executed if the target address is not a contract
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal returns (bool) {
        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(
            msg.sender,
            from,
            tokenId,
            _data
        );
        return (retval == _ERC721_RECEIVED);
    }

    // @dev Private function to clear current approval of a given token ID
    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}

contract ERC721Enumerable is ERC165, ERC721 {
    using SafeMath for uint256;
    mapping(address => uint256[]) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    /*
     * 0x780e9d63 ===
     *     bytes4(keccak256('totalSupply()')) ^
     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^
     *     bytes4(keccak256('tokenByIndex(uint256)'))
     */

    /**
     * @dev Constructor function
     */
    constructor() {
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    /**
     * @dev Gets the token ID at a given index of the tokens list of the requested owner
     * @param owner address owning the tokens list to be accessed
     * @param index uint256 representing the index to be accessed of the requested tokens list
     * @return uint256 token ID at the given index of the tokens list owned by the requested address
     */
    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        returns (uint256)
    {
        require(
            index < balanceOf(owner),
            "Index out of range"
        );
        return _ownedTokens[owner][index];
    }

    /**
     * @dev Gets the total amount of tokens stored by the contract
     * @return uint256 representing the total amount of tokens
     */
    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev Gets the token ID at a given index of all the tokens in this contract
     * Reverts if the index is greater or equal to the total number of tokens
     * @param index uint256 representing the index to be accessed of the tokens list
     * @return uint256 token ID at the given index of the tokens list
     */
    function tokenByIndex(uint256 index) public view returns (uint256) {
        require(index < totalSupply(), "Token index out of range");
        return _allTokens[index];
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to transferFrom, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _transferFromEnum(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        super._transferFrom(from, to, tokenId);
        _removeTokenFromOwnerEnumeration(from, tokenId);
        _addTokenToOwnerEnumeration(to, tokenId);
    }

    /**
     * @dev Internal function to mint a new token
     * Reverts if the given token ID already exists
     * @param to address the beneficiary that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _mintEnumeration(address to, uint256 tokenId) internal {
        super._mint(to, tokenId);
        _addTokenToOwnerEnumeration(to, tokenId);
        _addTokenToAllTokensEnumeration(tokenId);
    }

    /**
     * @dev Gets the list of token IDs of the requested owner
     * @param owner address owning the tokens
     * @return uint256[] List of token IDs owned by the requested address
     */
    function _tokensOfOwner(address owner)
        internal
        view
        returns (uint256[] storage)
    {
        return _ownedTokens[owner];
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the _ownedTokensIndex mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId)
        private
    {

        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; 
            _ownedTokensIndex[lastTokenId] = tokenIndex;
        }

        _ownedTokens[from].pop();

    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        _allTokens.pop();
        _allTokensIndex[tokenId] = 0;
    }
}

contract ERC721Metadata is ERC721Enumerable, usingOraclize {

    string private _name;
    string private _symbol;
    string private _baseTokenURI;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    mapping(uint256 => string) private _tokenURIs;

    /*
     * 0x5b5e139f ===
     *     bytes4(keccak256('name()')) ^
     *     bytes4(keccak256('symbol()')) ^
     *     bytes4(keccak256('tokenURI(uint256)'))
     */

    constructor(
        string memory namePar,
        string memory symbolPar,
        string memory baseTokenURIPar
    ) {
        // + TODO: set instance var values
        _name = namePar;
        _symbol = symbolPar;
        _baseTokenURI = baseTokenURIPar;

        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return _tokenURIs[tokenId];
    }

    function _setTokenURI(uint256 tokenId) internal {
        require(_exists(tokenId), "Token does not exist");
        string memory tokenUri = strConcat(_baseTokenURI, uint2str(tokenId));
        _tokenURIs[tokenId] = tokenUri;
    }
}

contract NFHousingToken is ERC721Metadata {
    constructor(string memory name, string memory symbol)
        ERC721Metadata(
            name,
            symbol,
            "https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/"
        )
    {}

    function mint(address to, uint256 tokenId)
        public
        onlyContractOwner
        whenNotPaused
        returns (bool)
    {
        super._mintEnumeration(to, tokenId);
        super._setTokenURI(tokenId);
        return true;
    }
}
