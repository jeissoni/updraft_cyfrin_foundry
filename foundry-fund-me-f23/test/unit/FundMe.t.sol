//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
   
   FundMe fundMe ;
   address USER = makeAddr("user");
   uint256 constant SEND_VALUE = 0.1 ether;
   uint256 constant STARTING_BALANCE = 10 ether;
   uint256 constant GAS_PRICE =1;

    function setUp() external {
        console.log("setUp");
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimunDolarIsFive() view public{

        console.log("testMinimunDolarIsFive");
        uint256 minimunDolar = fundMe.MINIMUM_USD();
        assertEq(minimunDolar, 5 * 10 ** 18);
    }

    function testOwnerIsSender() view public{
        console.log("testOwnerIsSender");
        address owner = fundMe.i_owner();
        assertEq(owner, msg.sender);
    }

    function testPriceFeedVersion() view public{
        console.log("testPriceFeedVersion");
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithouEnoughEth() public{
        console.log("testFundFailsWithouEnoughEth");
        vm.expectRevert(); //la siguiente linea espero que falle
        fundMe.fund(); //send 0 value
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.startPrank(USER);
        console.log("testFundUpdatesFundedDataStructure");    
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.addressToAmountFunded(USER);
        vm.stopPrank();
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFounderToArrayOfFounders() public{
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address founder = fundMe.funders(0);
        vm.stopPrank();
        assertEq(USER, founder);
    }

    modifier modifierFundMe(){
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerWithdraw()  public modifierFundMe{
        
        vm.startPrank(USER);
        vm.expectRevert(); //la siguiente linea espero que falle
        fundMe.withdraw(); //send 0 value
        vm.stopPrank();
    }

    function testWithDrawWithASingleFunder() public modifierFundMe{
        address owner = fundMe.i_owner();
        uint256 startingOwnerBalance = address(owner).balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        
        vm.startPrank(owner);
        fundMe.withdraw();
        vm.stopPrank();

        uint256 endingOwnerBalance = address(owner).balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingOwnerBalance, startingOwnerBalance + SEND_VALUE);
        assertEq(endingFundMeBalance, startingFundMeBalance - SEND_VALUE);
    }

    function testWithdrawFromMultipleFunders() public modifierFundMe{
        

        uint160 numberOfFunders = 10;
        uint160 startingFounder = 1;

        for (uint160 i = startingFounder; i < numberOfFunders; i++){
            //crear una cuenta y envia ETH a la direccion
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        
        uint256 startingOwnerBalance = address(fundMe.i_owner()).balance;

        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE); // set gas price
        vm.startPrank(fundMe.i_owner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 gasUsed = (gasStart - gasleft()) * tx.gasprice;
        console.log("Gas used: ", gasUsed);

        uint256 endingOwnerBalance = address(fundMe.i_owner()).balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

      
        assertEq(endingOwnerBalance, startingOwnerBalance + (numberOfFunders * SEND_VALUE));
        assertEq(endingFundMeBalance, 0);

    }

    function testWithdrawFromMultipleFundersCheaper() public modifierFundMe{
        

        uint160 numberOfFunders = 10;
        uint160 startingFounder = 1;

        for (uint160 i = startingFounder; i < numberOfFunders; i++){
            //crear una cuenta y envia ETH a la direccion
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        
        uint256 startingOwnerBalance = address(fundMe.i_owner()).balance;

        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE); // set gas price
        vm.startPrank(fundMe.i_owner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        uint256 gasUsed = (gasStart - gasleft()) * tx.gasprice;
        console.log("Gas used: ", gasUsed);

        uint256 endingOwnerBalance = address(fundMe.i_owner()).balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

      
        assertEq(endingOwnerBalance, startingOwnerBalance + (numberOfFunders * SEND_VALUE));
        assertEq(endingFundMeBalance, 0);

    }


}