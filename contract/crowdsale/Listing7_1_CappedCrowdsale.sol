pragma solidity ^0.4.18;
import "./Listing6_5_SimpleCrowdsale.sol";

contract CappedCrowdsale is SimpleCrowdsale {
    uint256 fundingCap;//#A

    constructor(uint256 _startTime, uint256 _endTime, 
    	uint256 _weiTokenPrice, uint256 _etherInvestmentObjective, 
    	uint256 _fundingCap)
    	SimpleCrowdsale(_startTime, _endTime, 
    	_weiTokenPrice, _etherInvestmentObjective)//#B
    	payable public 
    {
        require(_fundingCap > 0);
        fundingCap = _fundingCap;
    }
     
    function isValidInvestment(uint256 _investment) //#C
        internal view returns (bool) {
        bool nonZeroInvestment = _investment != 0;//#D
        bool withinCrowdsalePeriod = now >= startTime && now <= endTime; //#D

        bool isInvestmentBelowCap = investmentReceived + _investment < fundingCap; //#E
		
        return nonZeroInvestment && withinCrowdsalePeriod && isInvestmentBelowCap;
    }
}
//#A state variable for configuring funding cap
//#B configuring the rest of the state variables through the base constructor 
//#C this is overriding isValidInvestment()
//#D validations copied from SimpleCrowdsale.isValidInvestment()
//#E new validation checking the cap limit has not been breached 
