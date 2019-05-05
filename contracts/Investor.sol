pragma solidity^0.5.0;
import "./SafeMath.sol";
contract Investor {
    
    
    constructor () public {
        
    }
    
    address payable STOInstance;
    uint threshold;
    uint punishment;
    int majority;
    
    struct User{
        string name;
        string email;
        uint money; // the amount on investment
        uint voted; // the right to select target
        uint profit;
        bool valid; // Is the account valid
        address payable addr;
        bool isInvest;
    }
    address[] allInvestor;
    uint InvestVotenumber;
    uint DistributeVotenumber;
    uint private userId; 
    mapping (address => uint) public userToId;
    mapping (uint => address payable) public idToAddr;
    mapping (address => User) public users;
    uint public FundPool;
    
    bool public VoteResult;
    struct Vote{
        int Yes;
        int No; 
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
            profit: 0,
            valid: false,
            isInvest: false,
            addr: msg.sender
        });
        return userId;
    }
    
    function invest(uint YourIndex) payable public returns(bool){
        require(userToId[msg.sender] == YourIndex);
        require(userToId[idToAddr[YourIndex]] != 0 ,"Please create your info first");
        users[idToAddr[YourIndex]].voted = 1;
        users[idToAddr[YourIndex]].valid = true;
        users[idToAddr[YourIndex]].money += msg.value;
        FundPool +=msg.value;
        
        if(users[idToAddr[YourIndex]].isInvest == false) {
            allInvestor.push(idToAddr[YourIndex]);
            users[idToAddr[YourIndex]].isInvest = true;
        }
        return true;
    }
    
    function InvestTarget(address payable STO_, uint threshold_, uint PenaltyRatio) public returns(bool){
        require(VoteResult == false);
        STOInstance = STO_;
        threshold = threshold_;
        punishment = PenaltyRatio;
        return true;
    }
    
    function MoneyTransfer() public returns(bool){
        require(majority > 0);
        uint MoneyinPool = address(this).balance;
        STOInstance.transfer(MoneyinPool);
    }
    
    
    
    function VoteToTarget(uint YourIndex, uint YesFor1_or_NoFor0) public payable returns(bool){
        require(userToId[msg.sender] == YourIndex);
        require(users[idToAddr[YourIndex]].voted ==1);       //make sure voter have right
        require(YesFor1_or_NoFor0 == 1 || YesFor1_or_NoFor0 == 0 );
        if(YesFor1_or_NoFor0 == 1){
            VoteCondition.Yes += 1;
            majority += 1;
        }
        else{
            VoteCondition.No += 1;
        }
        users[idToAddr[YourIndex]].voted = 0; //投票權歸0
        InvestVotenumber +=1;
        if(allInvestor.length == InvestVotenumber){
            if((VoteCondition.No-VoteCondition.Yes) >= 0){
                for(uint i = 1; i<allInvestor.length + 1; i ++){
                idToAddr[i].transfer(users[idToAddr[i]].money);
                }
                VoteResult = false; //fail to have an investment target
                InvestVotenumber = 0;
                VoteCondition.Yes = 0;
                VoteCondition.No = 0;
                
            }
            else{
                VoteResult = true;
                InvestVotenumber = 0;
                VoteCondition.Yes = 0;
                VoteCondition.No = 0;
                
            }
        }
        return true;
    }
    
    
    function withdraw(uint YourIndex, uint withdrawAmount) payable public returns(uint){
        require(userToId[msg.sender] == YourIndex);
        require(withdrawAmount <= users[idToAddr[YourIndex]].money );
        if(VoteResult == true){
            if (users[idToAddr[YourIndex]].money >= withdrawAmount){
            users[idToAddr[YourIndex]].money -= withdrawAmount; // 調整所佔比例
            FundPool -= withdrawAmount;
            withdrawAmount = withdrawAmount * SafeMath.percent((100-punishment),100,3)/1000;
            idToAddr[YourIndex].transfer(withdrawAmount);
            //users[idToAddr[YourIndex]].money = users[idToAddr[YourIndex]].money -  withdrawAmount * SafeMath.percent(30,100,3)/1000;
                
                if(users[idToAddr[YourIndex]].money == 0){               //全部領完
                    users[idToAddr[YourIndex]].valid = false;
                    majority -= 1;
                }
                
                // fail to achive threshold
                if(FundPool <= threshold){
                    uint fundsAfterVoted = address(this).balance;
                    for(uint u =1; u <allInvestor.length + 1; u ++){
                        idToAddr[u].transfer(fundsAfterVoted * SafeMath.percent(users[idToAddr[u]].money,FundPool,3) / 1000);
                    }
                }
            
            
            }
        }
        if(VoteResult == false){
            if (users[idToAddr[YourIndex]].money >= withdrawAmount){
            users[idToAddr[YourIndex]].money -= withdrawAmount; // 調整所佔比例
            FundPool -= withdrawAmount;
            idToAddr[YourIndex].transfer(withdrawAmount);
            
                if(users[idToAddr[YourIndex]].money == 0){               //全部領完
                    users[idToAddr[YourIndex]].valid = false;
                }
            }
        }
        return users[idToAddr[YourIndex]].money;
    }
    

    
    
    
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
    function UpdateVote(uint index) external  returns(uint){
        return users[idToAddr[index]].voted = 0;
    }
    function UpdateProfit(uint index, uint theProfit) external returns(uint){
        return users[idToAddr[index]].profit = theProfit;
    }

}