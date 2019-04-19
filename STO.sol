pragma solidity^0.5.0;

contract STO{
    constructor() public{
        
    }
    function getBalance() view public returns(uint){
      return address(this).balance;
    } 
    
    function() external payable {
    }
}