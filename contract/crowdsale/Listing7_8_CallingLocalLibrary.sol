pragma solidity ^0.4.24;
contract SafeMathProxy { //#A
    function mul(uint256 a, uint256 b) public pure returns (uint256); //#B 
    function div(uint256 a, uint256 b) public pure returns (uint256); //#B
    function sub(uint256 a, uint256 b) public pure returns (uint256); //#B
    function add(uint256 a, uint256 b) public pure returns (uint256); //#B
}

contract Calculator {

    SafeMathProxy safeMath;   
    
    constructor(address _libraryAddress)
    {
        require(_libraryAddress != 0x0);
        safeMath = SafeMathProxy(_libraryAddress);//#D 
    }

    function calculateTheta(uint256 a, uint256 b) 
        public returns (uint256) {

        uint256 delta = safeMath.sub(a, b);//#E
        uint256 beta = safeMath.add(delta, 1000000);//#E
        uint256 theta = safeMath.mul(beta, b);//#E
        
        uint256 result = safeMath.div(theta, a);//#E
        
        return result;
    }
}
/*
#A This local abstract contract simply emulates the functionality offered by the library
#B These are the same function declarations present in the SafeMath library
#C SafeMath library address copied from Remix, as show in figure 6.8
#D Reference the SafeMath library deployed at the specified address
#E Calls to deployed SafeMath library
*/
//0xbbf289d846208c16edc8474705c748aff07732db