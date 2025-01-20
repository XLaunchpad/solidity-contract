// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721xSN} from "../nft-base/ERC721xSN.sol";
import {ERC1155xSN} from "../nft-base/ERC1155xSN.sol";
import {IStarknetMessaging} from "starknet/IStarknetMessaging.sol";
import {LibAccessControl, DEFAULT_ADMIN_ROLE} from "./LibAccessControl.sol";
import {NftLaunchedOnETH} from "src/libraries/constants/Events.sol";
import {NftType} from "src/libraries/constants/Types.sol";
import {Errors} from "src/libraries/constants/Errors.sol";
import {EncodeStringToUint256Array} from "src/libraries/utils/EncodeStringToUint256Array.sol";
import {
    XLAUNCHPAD_STORAGE_LOCATION,
    STARKNET_MESSAGING_ADDRESS,
    STORE_ADDRESSES_MESSAGE,
    LAUNCH_X_NFT_FROM_SN_MESSAGE,
    LAUNCH_X_NFT_FROM_ETH_SELECTOR
} from "src/libraries/constants/XLaunchpadConstants.sol";

library LibXLaunchpadETH {
    // STORAGE
    struct XLaunchpadStorage {
        uint256 xLaunchpadL2Address;
        mapping(address => uint256) l1L2AddressMap;
        mapping(uint256 => address) l2L1AddressMap;
    }

    function _getXLaunchpadStorage() internal pure returns (XLaunchpadStorage storage $) {
        assembly {
            $.slot := XLAUNCHPAD_STORAGE_LOCATION
        }
    }

    function setXLaunchpadL2Address(uint256 _l2Address) external {
        _getXLaunchpadStorage().xLaunchpadL2Address = _l2Address;
    }

    function getXLaunchpadL2Address() public view returns (uint256) {
        return _getXLaunchpadStorage().xLaunchpadL2Address;
    }

    function launchXNft(string calldata _name, string calldata _symbol, string calldata _uri, NftType nftType)
        internal
        returns (address nftAddress)
    {
        if (nftType == NftType.ERC721) {
            ERC721xSN erc721XSn = new ERC721xSN(msg.sender, address(this));
            erc721XSn.initialize(_name, _symbol, _uri);
            nftAddress = address(erc721XSn);
        } else if (nftType == NftType.ERC1155) {
            ERC1155xSN erc1155XSn = new ERC1155xSN(msg.sender, address(this));
            erc1155XSn.initialize(_name, _symbol, _uri);
            nftAddress = address(erc1155XSn);
        } else {
            revert Errors.InvalidNftType();
        }
        emit NftLaunchedOnETH(nftAddress, nftType);
    }

    // TODO
    function launchXNftFromSN(
        bytes calldata _name,
        bytes calldata _symbol,
        bytes calldata _uri_1,
        bytes calldata _uri_2,
        NftType nftType,
        uint256 starknetOwner
    ) public returns (bytes32 msgHash) {}

    function storeL2NftAddress(address l1Address, uint256 l2Address) public returns (bytes32 msgHash) {
        uint256[] memory payload = new uint256[](5);
        payload[0] = STORE_ADDRESSES_MESSAGE;
        payload[1] = uint256(uint160(l1Address));
        payload[2] = l2Address;

        msgHash = IStarknetMessaging(STARKNET_MESSAGING_ADDRESS).consumeMessageFromL2(
            _getXLaunchpadStorage().xLaunchpadL2Address, payload
        );

        XLaunchpadStorage storage $ = _getXLaunchpadStorage();
        $.l1L2AddressMap[l1Address] = l2Address;
        $.l2L1AddressMap[l2Address] = l1Address;
    }
}
