pragma solidity ^0.4.18;
import "./Listing7_F_ReleasableToken_interface.sol";
import "./Listing5_8_SimpleCoin.sol";//#A
contract ReleasableSimpleCoin is ReleasableToken, SimpleCoin { //#B
    bool public released = false;//#C

    modifier canTransfer() { //#D
        if(!released) {
            revert();
        }

        _;
    }

    constructor(uint256 _initialSupply) 
        SimpleCoin(_initialSupply) public {} //#E

    function release() onlyOwner public { //#F
        released = true;
    }

    function transfer(address _to, uint256 _amount) 
        canTransfer public { //#G
        super.transfer(_to, _amount);//#H
    }

    function transferFrom(address _from, address _to, uint256 _amount) canTransfer public returns (bool) {//#G
        super.transferFrom(_from, _to, _amount);//#H
    }  
}