// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibXLaunchpadSN, NftType} from "../libraries/LibXLaunchpadSN.sol";
import {LibXLaunchpadETH} from "../libraries/LibXLaunchpadETH.sol";
import {LibAccessControl, DEFAULT_ADMIN_ROLE} from "../libraries/LibAccessControl.sol";

contract XLaunchpadFacet {
    function setXLaunchpadL2Address(uint256 _l2Address) external {
        LibAccessControl._checkRole(DEFAULT_ADMIN_ROLE);
        LibXLaunchpadSN.setXLaunchpadL2Address(_l2Address);
    }

    function getXLaunchpadL2Address() public view returns (uint256) {
        return LibXLaunchpadSN._getXLaunchpadStorage().xLaunchpadL2Address;
    }

    function launchNftOnEthXSn(string calldata _name, string calldata _symbol, string calldata _uri, NftType nftType)
        external
        returns (address nftAddress, bytes32 msgHash, uint256 nonce)
    {
        return LibXLaunchpadSN.launchNftOnEthXSn(_name, _symbol, _uri, nftType);
    }

    function storeL2NftAddress(address l1Address, uint256 l2Address) public returns (bytes32 msgHash) {
        return LibXLaunchpadETH.storeL2NftAddress(l1Address, l2Address);
    }
}
