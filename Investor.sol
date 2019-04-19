pragma solidity^0.5.0;
import "./SafeMath.sol";
contract Investor {
    
    address payable STOInstance;
    constructor (address payable STO) public payable{
        STOInstance = STO;
    }
    
    struct User{
        string name;
        string email;
        uint money; // the amount on investment
        uint voted; // the right to vote
        //uint profit;
        bool valid; // Is the account valid
        address payable addr;
        bool isInvest;
    }
    address[] allInvestor;
    uint InvestVotenumber;
    uint DistributeVotenumber;
    uint private userId; //User[] users 會面臨到一個問題，就是id如何確認，就算用一個參數來記錄id，會是從1開始，而不是從0開始，除非有處理差異值
    mapping (address => uint) public userToId;
    mapping (uint => address payable) public idToAddr;
    mapping (address => User) public users;
    uint public FundPool;
    struct Vote{
        uint Yes;
        uint No; 
    }
    Vote public VoteCondition;
    
    function register(string memory _name,string memory _email) public returns(uint){
        require(userToId[msg.sender] == 0 ,"Your ID already exist");
        userId++;
        idToAddr[userId] = msg.sender;
        userToId[msg.sender] = userId;
        users[idToAddr[userId]] = User({
            name: _name,
            email: _email,
            money: 0,
            voted: 0,
            //profit: 0,
            valid: false,
            isInvest: false,
            addr: msg.sender
        });
        return userId;
    }
    
    function invest(uint YourIndex) payable public returns(uint){
        require(userToId[msg.sender] == YourIndex);
        require(userToId[idToAddr[YourIndex]] != 0 ,"Please create your info first");
        users[idToAddr[YourIndex]].voted = 1;
        users[idToAddr[YourIndex]].valid = true;
        users[idToAddr[YourIndex]].money += msg.value;
        FundPool +=users[idToAddr[YourIndex]].money;
        
        if(users[idToAddr[YourIndex]].isInvest == false) {
            allInvestor.push(idToAddr[YourIndex]);
            users[idToAddr[YourIndex]].isInvest == true;
        }
        return users[idToAddr[YourIndex]].money;
        return FundPool;
    }
    
    function withdraw(uint YourIndex, uint withdrawAmount) payable public returns(uint){
        require(userToId[msg.sender] == YourIndex);
        require(withdrawAmount <= users[idToAddr[YourIndex]].money );
        if (users[idToAddr[YourIndex]].money >= withdrawAmount){
            users[idToAddr[YourIndex]].money -= withdrawAmount;
            idToAddr[YourIndex].transfer(withdrawAmount);
            if(users[idToAddr[YourIndex]].money == 0){               //全部領完
                users[idToAddr[YourIndex]].valid = false;
            }
            FundPool -= withdrawAmount;
        }    
        return users[idToAddr[YourIndex]].money;
    }
    
    function VoteToInvest(uint YourIndex, uint YesFor1_or_NoFor0) public payable returns(bool){
        require(userToId[msg.sender] == YourIndex);
        require(users[idToAddr[YourIndex]].voted ==1);       //make sure voter have right
        require(YesFor1_or_NoFor0 == 1 || YesFor1_or_NoFor0 == 0 );
        if(YesFor1_or_NoFor0 == 1){
            VoteCondition.Yes += 1;
        }
        else{
            VoteCondition.No += 1;
        }
        users[idToAddr[YourIndex]].voted = 0; //投票權歸0
        InvestVotenumber +=1;
        if(allInvestor.length == InvestVotenumber && (VoteCondition.Yes-VoteCondition.No) > 0){  //多數決
            // transfer Money to Bank contract;
            STOInstance.transfer(FundPool);
            InvestVotenumber = 0;
            VoteCondition.Yes = 0;
            VoteCondition.No = 0;
        }
        return true;
    }
/*    
    function VoteToDistribute(uint YourIndex, uint YesFor1_or_NoFor0) external payable returns(bool){
        require(userToId[msg.sender] == YourIndex);
        require(users[idToAddr[YourIndex]].voted ==1);       //make sure voter have right
        require(YesFor1_or_NoFor0 == 1 || YesFor1_or_NoFor0 == 0 );
        if(YesFor1_or_NoFor0 == 1){
            VoteCondition.Yes += 1;
        }
        else{
            VoteCondition.No += 1;
        }
        users[idToAddr[YourIndex]].voted = 0; //投票權歸0
        DistributeVotenumber +=1;
        if(allInvestor.length == DistributeVotenumber && (VoteCondition.Yes-VoteCondition.No) > 0){  //多數決
            // distribute Money to Investors
            uint funds = address(this).balance;
                for(uint i= 1; i < allInvestor.length+1; i++){
                    users[idToAddr[i]].profit = funds * SafeMath.percent(users[idToAddr[i]].money, FundPool, 3) / 1000;
                }
                for(uint u = 1; u < allInvestor.length+1; u++){
                    users[idToAddr[u]].addr.transfer(users[idToAddr[u]].profit);
                }
            DistributeVotenumber = 0;
            VoteCondition.Yes = 0;
            VoteCondition.No = 0;
        }
        return true;
        
    }
*/
    function CheckFundPool() public view returns(uint){
        return address(this).balance;
    }
     
    function RearrangeVote() external returns(bool){
        for(uint i = 1; i < allInvestor.length+1; i++){
            if(users[idToAddr[i]].valid == true){
                users[idToAddr[i]].voted = 1;
            }
        }
    }
    
    function() external payable{}
    //Get Function
    function GetuserToId(address _add) external view returns(uint){
        return userToId[_add];
    }
    function GetidToAddr(uint i) external  payable returns(address payable){
        return users[idToAddr[i]].addr;
    }
    function GetUser_Votes(address _add) external view returns(uint){
        return  users[_add].voted;
    }
    function GetUser_Money(address _add) external view returns(uint){
        return  users[_add].money;
    }
    function GetInvestors() public view returns(address[] memory){
        return allInvestor;
    }

}