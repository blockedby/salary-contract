import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { SalaryManager, SalaryManager__factory } from "../typechain-types";

describe("Salary", function () {
    it("Should pay salary", async function () {
        const [deployer, alice, bob] = await ethers.getSigners();

        const Salary = await ethers.getContractFactory("SalaryManager") as SalaryManager__factory;
        const salary = await Salary.deploy(
            ethers.utils.parseEther("1000"),
            5
        ) as SalaryManager;

        await salary.deployed();
    });
});
