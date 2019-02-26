pragma solidity ^0.5.0;

contract RockPaperScissors {
/* Given a choice (e.g. "rock", "paper" or "scissors")
and a random/blinding string, returns a commitment
of the pair. Note calls to this function occur offline
(i.e. do not appear on the blockchain).
If you leave the'pure'
keyword in the function signature,
function calls to this won't publish to the blockchain.*/
address p1;
address p2;
bytes32 hashchoice1;
bytes32 hashchoice2;
string public choice1;
string public choice2;
address winner;
bool resolved;
bool p1played;
uint wager;

function encode_commitment(string memory choice, string memory rand) public pure returns (bytes32) { 
    return sha256(abi.encodePacked(sha256(bytes(choice))^sha256(bytes(rand))));

}
/* Accepts a commitment (generated via encode_commitment)
and a wager of ethereum*/
function play(bytes32 commitment) public payable { 
    if(!p1played){
        p1 = msg.sender;
        hashchoice1 = commitment;
        wager = msg.value;
        p1played = true;
    }
    else{
        p2 = msg.sender;
        hashchoice2 = commitment;
        if(msg.value < wager){
            require(msg.value >= wager);
        }
        else if(msg.value > wager){
            uint excess = msg.value - wager;
            msg.sender.transfer(excess); //probably won't work
        }
    }
}
/* Once both players have commited (called play()),
they reveal their choice and blinding string.
This function verifies the commitment is correct
and after both players submit, determines the winner.
*/
function reveal(string memory choice, string memory rand) public { 
    if(msg.sender == p1){
        assert(hashchoice1 == sha256(abi.encodePacked(sha256(bytes(choice))^sha256(bytes(rand)))));
        choice1 = choice;
    }
    else{
        assert(hashchoice2 == sha256(abi.encodePacked(sha256(bytes(choice))^sha256(bytes(rand)))));
        choice2 = choice;
    }
    if(keccak256(choice1) != keccak256("") && keccak256(choice2) != keccak256("")){
        if(sha256(choice1) == sha256("rock")){
            if(sha256(choice2) ==  sha256("rock")){
                winner = 0;
            }
            else if(sha256(choice2) ==  sha256("paper")){
                winner = p2;
            }
            else if(sha256(choice2) ==  sha256("scissors")){
                winner = p1;
            }
        }
        else if(sha256(choice1) == sha256("paper")){
            if(sha256(choice2) ==  sha256("rock")){
                winner = p1;
            }
            else if(sha256(choice2) ==  sha256("paper")){
                winner = 0;
            }
            else if(sha256(choice2) ==  sha256("scissors")){
                winner = p2;
            }
        }
        else if(sha256(choice1) == sha256("scissors")){
            if(sha256(choice2) ==  sha256("rock")){
                winner = p2;
            }
            else if(sha256(choice2) ==  sha256("paper")){
                winner = p1;
            }
            else if(sha256(choice2) ==  sha256("scissors")){
                winner = 0;
            }
        }

        resolved = true;
    }
}
/* After both players reveal, this allows the winner
to claim their reward (both wagers).
In the event of a tie, this function should let
each player withdraw their initial wager.
*/
function withdraw() public { 
    if(winner = 0 && resolved == true){
        p1.send(wager);
        p2.send(wager);
    }
    else if(resolved == true){
        winner.send(wager*2);
    }
}
}
