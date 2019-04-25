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
        uint profit;
        bool valid; // Is the account valid
        address payable addr;
        bool isInvest;
    }
    address[] allInvestor;
    uint InvestVotenumber;
    uint DistributeVotenumber;
    uint private userId; 
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
        FundPool +=users[idToAddr[YourIndex]].money;
        
        if(users[idToAddr[YourIndex]].isInvest == false) {
            allInvestor.push(idToAddr[YourIndex]);
            users[idToAddr[YourIndex]].isInvest == true;
        }
        return true;
    }
    
    function withdraw(uint YourIndex, uint withdrawAmount) payable public returns(uint){
        require(userToId[msg.sender] == YourIndex);
        require(withdrawAmount <= users[idToAddr[YourIndex]].money );
        if (users[idToAddr[YourIndex]].money >= withdrawAmount){
            users[idToAddr[YourIndex]].money -= withdrawAmount;
            users[idToAddr[YourIndex]].money = users[idToAddr[YourIndex]].money -  withdrawAmount * SafeMath.percent(10,100,3)/1000;
            idToAddr[YourIndex].transfer(withdrawAmount);
            
            if(users[idToAddr[YourIndex]].money == 0){               
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
        users[idToAddr[YourIndex]].voted = 0; //Vote right to be 0
        InvestVotenumber +=1;
        if(allInvestor.length == InvestVotenumber && (VoteCondition.Yes-VoteCondition.No) > 0){  //Majority decision
            // transfer Money to Bank contract;
            STOInstance.transfer(FundPool);
            InvestVotenumber = 0;
            VoteCondition.Yes = 0;
            VoteCondition.No = 0;
        }
        return true;
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