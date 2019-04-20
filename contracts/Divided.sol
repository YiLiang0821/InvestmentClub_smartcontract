pragma solidity^0.5.0;
import "./Investor.sol";

contract Divided{
    
    Investor investorInstance;
    
    constructor(address payable investorAddress)public payable{
        investorInstance = Investor(investorAddress);
    }
    
    uint VotetoDivide = 0;
    struct Vote{
        uint Yes;
        uint No; 
    }
    Vote public VoteCondition;
    
    
    function ReVote() public returns(bool){
        investorInstance.RearrangeVote(); //Give right to vote about distribute
    }
    function GetTotalProfit() view public returns(uint){
        return address(this).balance;
    }
    
    function VoteToDistribution(uint YourIndex, uint Yes1_or_No0) public payable returns(bool){
        require(investorInstance.GetuserToId(msg.sender) == YourIndex);
        require(investorInstance.GetUser_Votes(msg.sender) == 1);       //make sure voter have right
        require(Yes1_or_No0 == 1 || Yes1_or_No0 == 0 );
        if(Yes1_or_No0 == 1){
            VoteCondition.Yes += 1;
        }
        else{
            VoteCondition.No += 1;
        }
        investorInstance.UpdateVote(YourIndex); //Voted_right = 0
        VotetoDivide +=1;
        if(investorInstance.GetInvestors().length == VotetoDivide && (VoteCondition.Yes-VoteCondition.No) > 0){  //多數決
            // distribute Money to Investors
            uint funds = address(this).balance;
            
                for(uint i= 1; i < investorInstance.GetInvestors().length+1; i++){
                    
                }
            
                for(uint u = 1; u < investorInstance.GetInvestors().length+1; u++){
                    uint temp_profit = funds * SafeMath.percent(investorInstance.GetUser_Money(investorInstance.GetidToAddr(u)), investorInstance.FundPool(), 3) / 1000;
                    investorInstance.UpdateProfit(u, temp_profit);
                    investorInstance.GetidToAddr(u).transfer(temp_profit);
                }
            VotetoDivide = 0;
            VoteCondition.Yes = 0;
            VoteCondition.No = 0;
        }
        return true;
    }
    
    function() external payable{}
}