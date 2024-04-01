// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;
import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundFundMe,WithdrawFundMe} from "../../script/Interactions.s.sol";

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
 
 contract InteractionsTest is Test {
     FundMe fundme;
    uint256 constant SEND_VALUE = 0.01 ether;
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether;
    function setUp()external{
        DeployFundMe deployFundMe= new DeployFundMe();
         fundme = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }
    function testUserCanFundInteractions()public{
        FundFundMe fundFundMe=new FundFundMe();
        fundFundMe.fundFundMe(address(fundme));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundme));

        assert(address(fundme).balance==0);

    }
 }