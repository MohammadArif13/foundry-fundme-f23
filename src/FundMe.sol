// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe_NotOwner();
contract FundMe {
    using PriceConverter for uint256;
    // the below is grreat working
    uint256 public constant MINIMUM_USD = 5e18;
    address[] private s_funder;

    mapping(address => uint256) private s_addressToAmountFunded;
    function fund() public payable {
        // msg.value.getConversionRate();
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Did not send enough ETH"
        );
        s_funder.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }
    AggregatorV3Interface s_priceFeed;
    address private immutable i_owner;
    constructor(address _priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(_priceFeed);
    }
    function getVersion() public view returns (uint256) {
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x694AA1769357215DE4FAC081bf1f309aDC325306
        // );
        return s_priceFeed.version();
    }
    function cheaperWithdraw()public OnlyOwner{
        uint256 fundersLength=s_funder.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funder = s_funder[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funder = new address[](0);
         payable(msg.sender).transfer(address(this).balance);
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "Transaction failed");
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");

    }
    function withdraw() public OnlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funder.length;
            funderIndex++
        ) {
            address funder = s_funder[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funder = new address[](0);

        //we have three methods for withdraw
        //transfer,send and call

        payable(msg.sender).transfer(address(this).balance);
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "Transaction failed");
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }
    modifier OnlyOwner() {
        // require(msg.sender==i_owner,"Sender is not owner");
        if (msg.sender != i_owner) {
            revert FundMe_NotOwner();
        }
        _;
    }
    // receive() external payable {
    //     fund();
    // }
    // fallback() external payable {
    //     fund();
    // }


    function getAddressToAmountFunded(address fundingAddress) external view returns(uint256 ){
        return s_addressToAmountFunded[fundingAddress];
    }
    function getFunder(uint256 index) external view returns(address){
        return s_funder[index];
    }
    function getOwner() external view returns(address){
    return i_owner;
    }
}
