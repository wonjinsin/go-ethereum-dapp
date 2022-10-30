pragma solidity ^0.4.18;

contract FundingLimitStrategy{
    function isFullInvestmentWithinLimit(uint256 _investment, uint256 _fullInvestmentReceived)     
        public constant returns (bool);//#A
}
//#A This is the function performing the check on the funding cap, although it is not yet implemented at this stage


contract CappedFundingStrategy is FundingLimitStrategy {
    uint256 fundingCap;//#A

    function CappedFundingStrategy (uint256 _fundingCap) public {
        require(_fundingCap > 0);
        fundingCap = _fundingCap;
    }

    function isFullInvestmentWithinLimit(uint256 _investment, uint256 _fullInvestmentReceived) //#B
        public constant returns (bool) {
        
        bool check = _fullInvestmentReceived + _investment < fundingCap; 
        return check;
    }
}
//#A funding cap limit
//#B this is the same implementation as seen earlier i CappedTranchePricingCrowdsale 

contract UnlimitedFundingStrategy is FundingLimitStrategy {
    function isFullInvestmentWithinLimit(uint256 _investment, uint256 _fullInvestmentReceived) 
        public constant returns (bool) {
        return true; //#A
    }
}
//#A no check is performed because the funding is unlimited
