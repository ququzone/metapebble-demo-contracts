// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ISBT.sol";
import "./extensions/ISBTMetadata.sol";
import "openzeppelin-contracts/contracts/utils/Address.sol";
import "openzeppelin-contracts/contracts/utils/Context.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

abstract contract SBT is Context, ERC165, ISBT, ISBTMetadata {
    using Address for address;
    using Strings for uint256;

    struct OwnerToken {
        bool exist;
        uint256 tokenId;
    }

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Token total supply
    uint256 private _totalSupply;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token id
    mapping(address => OwnerToken) private _tokens;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(ISBT).interfaceId ||
            interfaceId == type(ISBTMetadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {SBT-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "SBT: address zero is not a valid owner");
        return _tokens[owner].exist ? 1 : 0;
    }

    /**
     * @dev See {SBT-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "SBT: invalid token ID");
        return owner;
    }

    /**
     * @dev See {ISBTMetadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {ISBTMetadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {ISBT-totalSupply}.
     */
    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {ISBT-tokenIdOf}.
     */
    function tokenIdOf(address from) public view virtual override returns (uint256) {
        OwnerToken memory ot = _tokens[from];
        require(ot.exist, "SBT: account does not have SBT");
        return ot.tokenId;
    }

    /**
     * @dev See {ISBTMetadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireAttested(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens start existing when they are attested (`_attest`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Safely attest `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract.
     *
     * Emits a {Transfer} event.
     */
    function _safeAttest(address to, uint256 tokenId) internal virtual {
        _safeAttest(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-SBT-_safeAttest-address-uint256-}[`_safeAttest`].
     */
    function _safeAttest(
        address to,
        uint256 tokenId,
        bytes memory
    ) internal virtual {
        _attest(to, tokenId);
    }

    /**
     * @dev Attest `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeAttest} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _attest(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "SBT: attest to the zero address");
        require(!_exists(tokenId), "SBT: token already attested");
        require(balanceOf(to) == 0, "SBT: account to already have SBT");

        _tokens[to] = OwnerToken(true, tokenId);
        _owners[tokenId] = to;

        emit Attest(to, tokenId);
        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = SBT.ownerOf(tokenId);

        delete _tokens[owner];
        delete _owners[tokenId];

        emit Burn(owner, tokenId);
        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Revoke SBT `from`.
     *
     * Requirements:
     *
     * - `from` must have token.
     *
     * Emits a {Transfer} event.
     */
    function _revoke(address from) internal virtual {
        OwnerToken memory ot = _tokens[from];
        require(ot.exist, "SBT: account does not have SBT");

        delete _tokens[from];
        delete _owners[ot.tokenId];

        emit Revoke(from, ot.tokenId);
        emit Transfer(from, address(0), ot.tokenId);
    }

    /**
     * @dev Reverts if the `tokenId` has not been attested yet.
     */
    function _requireAttested(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "SBT: invalid token ID");
    }
}
