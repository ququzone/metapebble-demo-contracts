// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IVerifyFeeSelector} from "./interface/IVerifyFeeSelector.sol";

contract VerifyFeeSelector is IVerifyFeeSelector, Ownable {
    event FeeManagerAdded(address indexed project, address indexed feeManager);
    event FeeManagerRemoved(address indexed project);

    address public immutable DEFAULT_FEE_MANAGER;

    mapping(address => address) feeManagerForProject;

    constructor(address _defaultFeeManager) {
        DEFAULT_FEE_MANAGER = _defaultFeeManager;
    }

    function fetchVerifyFeeManager(address project) external view returns (address) {
        address feeManager = feeManagerForProject[project];

        if (feeManager == address(0)) {
            feeManager = DEFAULT_FEE_MANAGER;
        }

        return feeManager;
    }

    function addFeeManager(address project, address feeManager) external onlyOwner {
        require(project != address(0), "Project cannot be null address");
        require(feeManager != address(0), "FeeManager cannot be null address");

        feeManagerForProject[project] = feeManager;

        emit FeeManagerAdded(project, feeManager);
    }

    function removeFeeManager(address project) external onlyOwner {
        require(feeManagerForProject[project] != address(0), "Project has no transfer manager");

        // Set it to the address(0)
        feeManagerForProject[project] = address(0);

        emit FeeManagerRemoved(project);
    }
}
