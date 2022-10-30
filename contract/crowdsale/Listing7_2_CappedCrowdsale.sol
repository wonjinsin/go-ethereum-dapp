pragma solidity ^0.4.18;
import "./Listing7_A_SimpleCrowdsale_forCapped.sol";

contract CappedCrowdsale is SimpleCrowdsale {
     uint256 fundingCap;

     constructor(uint256 _startTime, uint256 _endTime, 
    	uint256 _weiTokenPrice, uint256 _etherInvestmentObjective, 
    	uint256 _fundingCap)
    	SimpleCrowdsale(_startTime, _endTime, 
    	_weiTokenPrice, _etherInvestmentObjective)
    	payable public 
    {
        require(_fundingCap > 0);
        fundingCap = _fundingCap;
    }
     
    function isFullInvestmentWithinLimit(uint256 _investment) 
        internal constant returns (bool) {
        bool check = investmentReceived + _investment < fundingCap; //#A
        return check;
    }
}
//#A Now referencing a modified version of SimpleCrowdsale implementing isFullInvestmentWithinLimit
//#B this is the check that was being performed on the previously in the overriden isValidInvestment() function

