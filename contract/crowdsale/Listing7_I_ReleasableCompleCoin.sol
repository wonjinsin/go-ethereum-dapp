pragma solidity ^0.4.18;
import "./Listing7_F_ReleasableToken_interface.sol";
import "./Listing7_4_concreteCrowdsaleContracts.sol";

contract ReleasableComplexCoin is ReleasableToken {
    function mint(address _beneficiary, uint256 _numberOfTokens) external {}
    function release() external {}
    function transfer(address _to, uint256 _amount) external {}
}

contract UnlimitedFixedPricingCrowdsaleWithComplexCoin 
    is UnlimitedFixedPricingCrowdsale {
    
    constructor(uint256 _startTime, uint256 _endTime, 
    	uint256 _weiTokenPrice, uint256 _etherInvestmentObjective)
    	UnlimitedFixedPricingCrowdsale(_startTime, _endTime, //#A
    	_weiTokenPrice, _etherInvestmentObjective)
    	payable public  {
    }
    
    function createToken() 
        internal returns (ReleasableToken) {
            return new ReleasableComplexCoin();
        }
}