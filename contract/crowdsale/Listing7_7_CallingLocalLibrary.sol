pragma solidity ^0.4.24;
import './Listing7_6_SafeMath.sol';

contract Calculator {
    function calculateTheta(uint256 a, uint256 b) returns (uint256) {
        uint256 delta = SafeMath.sub(a, b);//#A
        uint256 beta = SafeMath.add(delta, 1000000);//#A
        uint256 theta = SafeMath.mul(beta, b);//#A
        
        uint256 result = SafeMath.div(theta, a);//#A
        
        return result;
    }
}
//#A SafeMath library functions are all prefixed with SafeMath