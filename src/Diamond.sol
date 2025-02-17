// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * \
 * Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
 * EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
 *
 * Implementation of a diamond.
 * /*****************************************************************************
 */
import {LibDiamond, DiamondInitArgs} from "src/libraries/LibDiamond.sol";
import {LibAccessControl, DEFAULT_ADMIN_ROLE} from "src/libraries/LibAccessControl.sol";
import {FacetCut} from "src/interfaces/IDiamondCut.sol";

error Diamond__FunctionNotFound(bytes4 _functionSelector);

contract Diamond {
    constructor(address _contractAdmin, FacetCut[] memory _diamondCut, DiamondInitArgs memory _args) payable {
        // Grant `_contractAdmin` address the default admin role
        LibAccessControl._grantRole(DEFAULT_ADMIN_ROLE, _contractAdmin);

        // Add the diamondCut external function from the diamondCutFacet
        LibDiamond.diamondCut(_diamondCut, _args.init, _args.initCalldata);
    }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        LibDiamond.DiamondStorage storage ds;
        bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;

        // get diamond storage
        assembly {
            ds.slot := position
        }

        // get facet from function selector
        address facet = ds.selectorToFacetAndPosition[msg.sig].facetAddress;
        if (facet == address(0)) {
            revert Diamond__FunctionNotFound(msg.sig);
        }

        // Execute external function from facet using delegatecall and return any value.
        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())
            // execute function call using the facet
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}
