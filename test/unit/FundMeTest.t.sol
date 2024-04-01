// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {PriceConverter} from "../../src/PriceConverter.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundme;
    uint256 constant SEND_VALUE = 0.01 ether;
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether;
    function setUp() external {
        // fundme=new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }
    function testMinimumUsdIsFive() public view {
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }
    function testIsOwnerSender() public view {
        assertEq(fundme.getOwner(), msg.sender);
    }
    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundme.getVersion();
        assertEq(version, 4);
    }
    modifier funded() {
        vm.prank(USER);

        fundme.fund{value: SEND_VALUE}();
        _;
    }
    function testFundFailWithoutEnoughEth() public {
        vm.expectRevert();
        fundme.fund();
    }
    function testFundUpdatesFundedDataStructure() public funded {
        // fundme.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundme.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }
    function testAddsFundersToArrayOfFunders() public funded {
        // fundme.fund{value: SEND_VALUE}();
        address funder = fundme.getFunder(0);
        // assertEq(funder, address(this));
        assertEq(funder, USER);
    }
    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER);
        vm.expectRevert();
        fundme.fund();
    }
    function testWithdrawWithASingleFunder() public funded {
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        vm.prank(fundme.getOwner());
        fundme.withdraw();
        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingfundmeBalance = address(fundme).balance;

        assertEq(endingfundmeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }
    function testWithdrawFromMultipleFunders() public {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();
        assert(address(fundme).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundme.getOwner().balance
        );
    }
    function testWithdrawFromMultipleFundersCheaper() public {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        vm.startPrank(fundme.getOwner());
        fundme.cheaperWithdraw();
        vm.stopPrank();
        assert(address(fundme).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundme.getOwner().balance
        );
    }
}
