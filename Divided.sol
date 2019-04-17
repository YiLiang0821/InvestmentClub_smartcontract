pragma solidity^0.4.25;
import "./Investor.sol";

contract Divided{
    //address investorInstance;
    Investor investorInstance;
    
    constructor(address investorAddress)public payable{
        investorInstance = Investor(investorAddress);
        investorInstance.RearrangeVote(); //Give right to vote about distribute
        
    }
    function GetFundMoney() view public returns(uint) {
        return investorInstance.CheckFundPool();
    }
    
    function GetProfit() view public returns(uint){
        return address(this).balance;
    }
    
    function VoteToDistribution(uint index, uint Yes1_or_No0) public payable returns(uint){
        investorInstance.VoteToDistribute(index,Yes1_or_No0);
    }
    function() payable{}
}