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

    struct Date {
        uint256 year;
        uint256 month;
        uint256 day;
    }

    address public master;
    address public slave;
    address public token;

    uint8 tokenDecimals;

    bool isApproved;

    uint256 public salary;

    uint256 public payDay;

    Date public lastPayedDate;

    uint256 proposalId;

    constructor(uint256 _salary, uint256 _payDay) {
        slave = msg.sender;
        salary = _salary * 1 ether;
        if (_payDay > 32) {
            assert(false);
        }
        payDay = _payDay;

        (uint256 year, uint256 month, uint256 day) = block
            .timestamp
            .timestampToDate();
        console.log("year: %s, month: %s, day: %s", year, month, day);
    }

    function getPaid() public onlySlave {
        Date memory today = currentDate();

        if (today.month > lastPayedDate.month && today.day >= payDay) {
            lastPayedDate = today;
            uint256 balance = IERC20(token).balanceOf(address(this));
            if (balance >= salary) {
                IERC20(token).transfer(msg.sender, salary);
            } else {
                revert NotEnoughFund();
            }
        }
    }

    function updateToken(address _token) public notZeroAddress(_token) {
        // require both signatures
        token = _token;
        tokenDecimals = IERC20Metadata(token).decimals();
    }

    function requestPromotion() external pure {}

    function promote(uint256 _newSalary) public onlyMaster {
        assert(_newSalary > salary);
        salary = _newSalary;
    }

    function requestDemotion() external pure {}

    function demote(uint256 _newSalary) public onlySlave {
        // require slave approve
        assert(_newSalary < salary);
        salary = _newSalary;
    }

    function currentDate() public view returns (Date memory today) {
        (uint256 year, uint256 month, uint256 day) = block
            .timestamp
            .timestampToDate();
        return Date(year, month, day);
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
