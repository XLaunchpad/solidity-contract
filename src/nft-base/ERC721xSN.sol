// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {ERC721BurnableUpgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import {ERC721EnumerableUpgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import {ERC721PausableUpgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721PausableUpgradeable.sol";
import {ERC721URIStorageUpgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import {ERC2981Upgradeable} from "@openzeppelin/contracts-upgradeable/token/common/ERC2981Upgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {IStarknetMessaging} from "starknet/IStarknetMessaging.sol";

contract ERC721xSN is
    Initializable,
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    ERC721URIStorageUpgradeable,
    ERC721PausableUpgradeable,
    ERC2981Upgradeable,
    AccessControlUpgradeable,
    ERC721BurnableUpgradeable,
    UUPSUpgradeable
{
    address private constant STARKNET_MESSAGING_ADDRESS = 0xc662c410C0ECf747543f5bA90660f6ABeBD9C8c4;

    /// @custom:storage-location erc7201:erc721.x.sn.storage.UUPSStorage
    struct ERC721xSNStorage {
        string _baseUri;
        uint256 l2Address;
    }

    // keccak256(abi.encode(uint256(keccak256("erc721.x.sn.storage.UUPSStorage")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC721_X_SN_STORAGE_LOCATION =
        0x497e4d8445f57ae1416bbbe76d8e46a9f9ade818b49abfedfc36cbd6cab3b600;

    function _getERC721xSNStorage() private pure returns (ERC721xSNStorage storage $) {
        assembly {
            $.slot := ERC721_X_SN_STORAGE_LOCATION
        }
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address defaultAdmin, address royaltyRecipient) {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setDefaultRoyalty(royaltyRecipient, 500);
    }

    function initialize(string memory _name, string memory _symbol, string memory _uri)
        public
        initializer
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        __ERC721_init(_name, _symbol);
        _setBaseURI(_uri);
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();
        __ERC721Pausable_init();
        __AccessControl_init();
        __ERC721Burnable_init();
        __UUPSUpgradeable_init();
    }

    function _setBaseURI(string memory baseURI) internal virtual {
        _getERC721xSNStorage()._baseUri = baseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return _getERC721xSNStorage()._baseUri;
    }

    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function safeMint(address to, uint256 tokenId, string memory uri) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function transferToStarkNet(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not owner");

        // Burn NFT to lock on L1
        _burn(tokenId);

        // Notify L2
        uint256[] memory payload;
        payload[0] = uint256(uint160(msg.sender)); // L1 user address
        payload[1] = tokenId;

        // IStarknetMessaging(STARKNET_MESSAGING_ADDRESS).sendMessageToL2(
        //     _getERC721xSNStorage().l2Address,
        //     keccak256("mint_from_l1(address,uint256)"),
        //     payload
        // );
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721PausableUpgradeable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
    {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(
            ERC721Upgradeable,
            ERC721EnumerableUpgradeable,
            ERC721URIStorageUpgradeable,
            ERC2981Upgradeable,
            AccessControlUpgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
