pragma solidity ^0.4.24;
import "./Listing7_D_SimpleCrowdsale_fundingLimitStrategy.sol";

contract TranchePricingCrowdsale is SimpleCrowdsale  { //#A

    struct Tranche {
        uint256 weiHighLimit;
        uint256 weiTokenPrice;
    }
    
    mapping(uint256 => Tranche) public trancheStructure;//#B
    uint256 public currentTrancheLevel;//#C

    constructor(uint256 _startTime, uint256 _endTime, 
    	uint256 _etherInvestmentObjective) 
    	SimpleCrowdsale(_startTime, _endTime,
    	   1, _etherInvestmentObjective) //#D
    	payable public
    {
        trancheStructure[0] = Tranche(3000 ether, 0.002 ether);//#E
        trancheStructure[1] = Tranche(10000 ether, 0.003 ether);//#E
        trancheStructure[2] = Tranche(15000 ether, 0.004 ether);//#E
        trancheStructure[3] = Tranche(1000000000 ether, 0.005 ether);//#E
        
        currentTrancheLevel = 0;//#D
    } 
    
    function calculateNumberOfTokens(uint256 investment) //#F
        internal returns (uint256) {
        updateCurrentTrancheAndPrice();
        return investment / weiTokenPrice; 
    }

    function updateCurrentTrancheAndPrice() 
        internal {
        uint256 i = currentTrancheLevel;
      
        while(trancheStructure[i].weiHighLimit < investmentReceived) 
            ++i;
          
        currentTrancheLevel = i;

        weiTokenPrice = trancheStructure[currentTrancheLevel].weiTokenPrice;
    }
}

contract FixedPricingCrowdsale is SimpleCrowdsale {     

    constructor(uint256 _startTime, uint256 _endTime, 
    	uint256 _weiTokenPrice, uint256 _etherInvestmentObjective)
    	SimpleCrowdsale(_startTime, _endTime, 
    	_weiTokenPrice, _etherInvestmentObjective)
    	payable public  {
    }

    function calculateNumberOfTokens(uint256 investment) 
        internal returns (uint256) {
        return investment / weiTokenPrice;
    }    
}