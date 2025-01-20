// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Diamond} from "src/Diamond.sol";
import {FacetCut} from "src/interfaces/IDiamondCut.sol";
import {DiamondInitArgs} from "src/libraries/LibDiamond.sol";

contract XLaunchpad is Diamond {
    constructor(address admin, FacetCut[] memory facets, DiamondInitArgs memory initData)
        Diamond(admin, facets, initData)
    {}
}
