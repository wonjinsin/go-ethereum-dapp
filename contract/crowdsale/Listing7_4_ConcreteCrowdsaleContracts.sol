pragma solidity ^0.4.24;
import "./Listing7_C_FundingLimitStrategies.sol";
import "./Listing7_E_PricingStrategies.sol";

contract UnlimitedFixedPricingCrowdsale is FixedPricingCrowdsale {
    
    constructor(uint256 _startTime, uint256 _endTime, 
    	uint256 _weiTokenPrice, uint256 _etherInvestmentObjective)
    	FixedPricingCrowdsale(_startTime, _endTime, //#A
    	_weiTokenPrice, _etherInvestmentObjective)
    	payable public  {
    }
    
    function createFundingLimitStrategy() 
        internal returns (FundingLimitStrategy) {
        
        return new UnlimitedFundingStrategy(); //#B
    }
}

contract CappedFixedPricingCrowdsale is FixedPricingCrowdsale {
    
    constructor(uint256 _startTime, uint256 _endTime, 
    	uint256 _weiTokenPrice, uint256 _etherInvestmentObjective)
    	FixedPricingCrowdsale(_startTime, _endTime, //#A
    	_weiTokenPrice, _etherInvestmentObjective)
    	payable public  {
    }
    
    function createFundingLimitStrategy() 
        internal returns (FundingLimitStrategy) {
        
        return new CappedFundingStrategy(10000); //#B
    }
}

contract UnlimitedTranchePricingCrowdsale is TranchePricingCrowdsale {
    
    constructor(uint256 _startTime, uint256 _endTime, 
    	uint256 _etherInvestmentObjective)
    	TranchePricingCrowdsale(_startTime, _endTime, //#A
    	_etherInvestmentObjective)
    	payable public  {
    }
    
    function createFundingLimitStrategy() 
        internal returns (FundingLimitStrategy) {
        
        return new UnlimitedFundingStrategy(); //#B
    }
}

contract CappedTranchePricingCrowdsale is TranchePricingCrowdsale {
    
    constructor(uint256 _startTime, uint256 _endTime, 
    	uint256 _etherInvestmentObjective)
    	TranchePricingCrowdsale(_startTime, _endTime, //#A
    	_etherInvestmentObjective)
    	payable public  {
    }
    
    function createFundingLimitStrategy() 
        internal returns (FundingLimitStrategy) {
        
        return new CappedFundingStrategy(10000); //#B
    }
}