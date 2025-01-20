// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";

import {XLaunchpad} from "src/XLaunchpad.sol";
import {DiamondCutFacet} from "src/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "src/facets/DiamondLoupeFacet.sol";
import {LaunchpadFacet} from "src/facets/LaunchpadFacet.sol";
import {IDiamondCut, FacetCut, FacetCutAction} from "src/interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "src/interfaces/IDiamondLoupe.sol";
import {LibDiamond, DiamondInitArgs} from "src/libraries/LibDiamond.sol";
import {IERC165} from "openzeppelin-contracts/contracts/interfaces/IERC165.sol";
import {ERC165Init} from "src/initializers/ERC165Init.sol";

contract DeployXLaunchpad is Script {
    DiamondCutFacet diamondCutFacet = DiamondCutFacet(0x1BbF348341D509d368AFBeb77aF0BF941b1E04Cd);
    DiamondLoupeFacet diamondLoupeFacet;
    LaunchpadFacet launchpadFacet;
    ERC165Init erc165Init;
    XLaunchpad xLaunchpad = XLaunchpad(payable(0x8A30774B2671dfAd7Ebc4087Cf629F9B535b1324));

    function run() public {
        vm.startBroadcast();
        diamondLoupeFacet = new DiamondLoupeFacet();
        launchpadFacet = new LaunchpadFacet();
        erc165Init = new ERC165Init();

        console.log("diamondCutFacet deployed at: ", address(diamondCutFacet));
        console.log("diamondLoupeFacet deployed at: ", address(diamondLoupeFacet));
        console.log("launchpadFacet deployed at: ", address(launchpadFacet));

        FacetCut[] memory cut = new FacetCut[](3);

        // bytes4[] memory diamondCutSelectors = new bytes4[](1);
        // diamondCutSelectors[0] = DiamondCutFacet.diamondCut.selector;

        bytes4[] memory loupeSelectors = new bytes4[](5);
        loupeSelectors[0] = IDiamondLoupe.facets.selector;
        loupeSelectors[1] = IDiamondLoupe.facetFunctionSelectors.selector;
        loupeSelectors[2] = IDiamondLoupe.facetAddresses.selector;
        loupeSelectors[3] = IDiamondLoupe.facetAddress.selector;
        loupeSelectors[4] = IERC165.supportsInterface.selector;

        bytes4[] memory launchpadFacetSelectors = new bytes4[](4);
        launchpadFacetSelectors[0] = LaunchpadFacet.setXLaunchpadL2Address.selector;
        launchpadFacetSelectors[1] = LaunchpadFacet.getXLaunchpadL2Address.selector;
        launchpadFacetSelectors[2] = LaunchpadFacet.launchNftOnEthXSn.selector;
        launchpadFacetSelectors[3] = LaunchpadFacet.storeL2NftAddress.selector;

        // cut[0] = FacetCut({
        //     facetAddress: address(diamondCutFacet),
        //     action: FacetCutAction.Add,
        //     functionSelectors: diamondCutSelectors
        // });

        cut[0] = FacetCut({
            facetAddress: address(diamondLoupeFacet),
            action: FacetCutAction.Add,
            functionSelectors: loupeSelectors
        });

        cut[1] = FacetCut({
            facetAddress: address(launchpadFacet),
            action: FacetCutAction.Add,
            functionSelectors: launchpadFacetSelectors
        });

        DiamondInitArgs memory args =
            DiamondInitArgs({init: address(erc165Init), initCalldata: abi.encode(keccak256("init()"))});

        // xLaunchpad = new XLaunchpad(msg.sender, cut, args);

        IDiamondCut(address(xLaunchpad)).diamondCut(cut, args.init, args.initCalldata);

        console.log("XLaunchpad deployed at: ", address(xLaunchpad));

        vm.stopBroadcast();
    }
}
