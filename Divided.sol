pragma solidity^0.4.25;
import "./Investor.sol";

contract Divided{
    //address investorInstance;
    Investor investorInstance;
    
    constructor(address investorAddress)public{
        investorInstance = Investor(investorAddress);
        investorInstance.RearrangeVote(); //Give right to vote about distribute
        
    }
    function GetFundMoney() view public returns(uint) {
        return investorInstance.CheckFundPool();
    }
    
    function Proportion_(uint index) view public returns(uint){
        investorInstance.GetProportion(index);
    }
    
    function VoteToDistribution(uint index, uint Yes1_or_No0) public returns(uint){
        investorInstance.RearrangeVote(); //Give right to vote about distribute
        investorInstance.VoteToDistribute(index,Yes1_or_No0);
    }
    
}