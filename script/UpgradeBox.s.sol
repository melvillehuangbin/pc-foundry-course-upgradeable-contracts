// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "../lib/forge-std/src/Script.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";
import {ERC1967Proxy} from  "../lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract UpgradeBox is Script {

    function run() external returns(address) {
        // get most recent deployment of ERC1967Proxy
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);
        // get new implementation contract BoxV2
        vm.startBroadcast();
        BoxV2 newBox = new BoxV2();
        vm.stopBroadcast();
        // upgrade the implementation contract (Box)
        address proxy = upgradeBox(mostRecentlyDeployed, address(newBox));
        // return the proxy address
        return proxy;
    }

    function upgradeBox(address proxyAddress, address newBox) public returns(address) {
        vm.startBroadcast();
        // get the proxy address of BoxV1
        BoxV1 proxy = BoxV1(proxyAddress);
        // upgrade that proxy
        proxy.upgradeTo(address(newBox));
        // return the new proxy address and deploy it
        vm.stopBroadcast();
        return address(proxy);
    }
}