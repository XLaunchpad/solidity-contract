// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {NftType} from "./Types.sol";

// Launchpad Events
event NftLaunchedOnETH(address indexed, NftType);
event NftLaunchedOnSN(uint256 indexed, NftType);