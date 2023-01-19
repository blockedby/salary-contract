// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20, IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {BokkyPooBahsDateTimeLibrary} from "./libraries/BokkyPooBahsDateTimeLibrary.sol";

error NotMaster(address caller, address master);
error NotSlave(address caller, address slave);
error NotEnoughFund();
error ZeroAddress();
error ZeroAmount();

import "hardhat/console.sol";

contract SalaryManager is ReentrancyGuard {
    using BokkyPooBahsDateTimeLibrary for uint256;

    address public master;
    address public slave;
    address public token;

    uint8 tokenDecimals;

    bool isApproved;

    uint256 public salary;

    uint256 public payDay;
    
    constructor(uint256 _salary, uint256 _payDay) {
        slave = msg.sender;
        salary = _salary * 1 ether;
        if (_payDay > 32) {
            assert(false);
        }
        payDay = _payDay;

        block.timestamp.timestampToDateTime();
    }

    function updateToken(address _token) public onlyMaster {
        token = _token;
        tokenDecimals = IERC20Metadata(token).decimals();
    }

    function promote(uint256 _newSalary) public onlySlave {
        salary = _newSalary;
    }

    function demote(uint256 _newSalary) public onlySlave {
        // require slave approve
        salary = _newSalary;
    }

    function getPaid() public onlySlave {
        // uint256 nextPayday = lastPayday + 30 days;
        // lastPayday = nextPayday;
        IERC20(token).transfer(msg.sender, salary);
    }

    modifier onlyMaster() {
        if (msg.sender == master) {
            _;
        } else {
            revert NotMaster(msg.sender, master);
        }
    }

    modifier onlySlave() {
        if (msg.sender == slave) {
            _;
        } else {
            revert NotSlave(msg.sender, slave);
        }
    }

    modifier notZeroAddress(address _address) {
        if (_address == address(0)) {
            revert ZeroAddress();
        } else {
            _;
        }
    }

    modifier NonZeroAmount(uint256 _amount) {
        if (_amount == 0) {
            revert ZeroAmount();
        } else {
            _;
        }
    }
}
