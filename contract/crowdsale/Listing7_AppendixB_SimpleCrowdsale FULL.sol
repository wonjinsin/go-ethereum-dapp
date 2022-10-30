/*
 NOTE: copied from: 
 * Listing7_F_ReleasableToken_interface.sol
 * Listing7_G_ReleasableSimpleCoin_ReleasableToken_interface.sol
 * Listing7_C_FundingStrategies.sol
 * Listing7_H_SimpleCrowdsale_ReleasableToken.sol
 * Listing7_E_PricingStrategies.sol
 * Listing7_4_concreteCrowdsaleContracts.sol
*/

pragma solidity ^0.4.24;

import "./Listing5_8_SimpleCoin.sol";
import "./Listing6_4_Ownable.sol";

interface ReleasableToken {
    function mint(address _beneficiary, uint256 _numberOfTokens) external;
    function release() external;
    function transfer(address _to, uint256 _amount) external;
}

contract ReleasableSimpleCoin is ReleasableToken, SimpleCoin { 
    bool public released = false;

    modifier canTransfer() { 
        if(!released) {
            revert();
        }

        _;
    }

    constructor(uint256 _initialSupply) 
        SimpleCoin(_initialSupply) public {} 

    function release() onlyOwner public { 
        released = true;
    }

    function transfer(address _to, uint256 _amount) 
        canTransfer public { 
        super.transfer(_to, _amount);
    }

    function transferFrom(address _from, address _to, uint256 _amount) canTransfer public returns (bool) {
        super.transferFrom(_from, _to, _amount);
    }  
}

contract FundingLimitStrategy{
    function isFullInvestmentWithinLimit(uint256 _investment, uint256 _fullInvestmentReceived)     
        public view returns (bool);
}

contract CappedFundingStrategy is FundingLimitStrategy {
    uint256 fundingCap;

    constructor(uint256 _fundingCap) public {
        require(_fundingCap > 0);
        fundingCap = _fundingCap;
    }

    function isFullInvestmentWithinLimit(uint256 _investment, uint256 _fullInvestmentReceived) 
        public view returns (bool) {
        
        bool check = _fullInvestmentReceived + _investment < fundingCap; 
        return check;
    }
}

contract UnlimitedFundingStrategy is FundingLimitStrategy {
    function isFullInvestmentWithinLimit(uint256 _investment, uint256 _fullInvestmentReceived) 
        public view returns (bool) {
        return true;
    }
}

contract SimpleCrowdsale is Ownable {
    uint256 public startTime;
    uint256 public endTime; 
    uint256 public weiTokenPrice;
    uint256 public weiInvestmentObjective;
       
    mapping (address => uint256) public investmentAmountOf;
    uint256 public investmentReceived;
    uint256 public investmentRefunded;
    
    bool public isFinalized;
    bool public isRefundingAllowed; 

    ReleasableToken  public crowdsaleToken; 
    
    FundingLimitStrategy internal fundingLimitStrategy;
    
    constructor(uint256 _startTime, uint256 _endTime, 
    	uint256 _weiTokenPrice, uint256 _etherInvestmentObjective) 
    	payable public
    {
        require(_startTime >= now);
        require(_endTime >= _startTime);
        require(_weiTokenPrice != 0);
        require(_etherInvestmentObjective != 0);
    	
        startTime = _startTime;
        endTime = _endTime;
        weiTokenPrice = _weiTokenPrice;
        weiInvestmentObjective = _etherInvestmentObjective * 1000000000000000000;
    
        crowdsaleToken = createToken();
        isFinalized = false;
        fundingLimitStrategy = createFundingLimitStrategy();
    } 
    
    event LogInvestment(address indexed investor, uint256 value);
    event LogTokenAssignment(address indexed investor, uint256 numTokens);
    event Refund(address investor, uint256 value);
    
    function invest() public payable {
        require(isValidInvestment(msg.value)); 
    	
        address investor = msg.sender;
        uint256 investment = msg.value;
    	
        investmentAmountOf[investor] += investment; 
        investmentReceived += investment; 
    	
        assignTokens(investor, investment);
        emit LogInvestment(investor, investment);
    }
    
    function createToken() 
        internal returns (ReleasableToken) {
            return new ReleasableSimpleCoin(0);
        }
        
    function createFundingLimitStrategy() 
        internal returns (FundingLimitStrategy);

    function isValidInvestment(uint256 _investment) 
        internal view returns (bool) {
        bool nonZeroInvestment = _investment != 0;
        bool withinCrowdsalePeriod = now >= startTime && now <= endTime; 
    		
        return nonZeroInvestment && withinCrowdsalePeriod
           && fundingLimitStrategy.isFullInvestmentWithinLimit(_investment, investmentReceived);
    }
    
    function assignTokens(address _beneficiary, 
        uint256 _investment) internal {
    
        uint256 _numberOfTokens = calculateNumberOfTokens(_investment); 
    	
        crowdsaleToken.mint(_beneficiary, _numberOfTokens);
    }
    
    function calculateNumberOfTokens(uint256 _investment) 
        internal returns (uint256) {
        return _investment / weiTokenPrice; 
    }
    
    function finalize() onlyOwner public {
        if (isFinalized) revert();
    
        bool isCrowdsaleComplete = now > endTime; 
        bool investmentObjectiveMet = investmentReceived >= weiInvestmentObjective;
            
        if (isCrowdsaleComplete)
        {     
            if (investmentObjectiveMet)
                crowdsaleToken.release();
            else 
                isRefundingAllowed = true;
    
            isFinalized = true;
        }               
    }
    
    function refund() public {
        if (!isRefundingAllowed) revert();
    
        address investor = msg.sender;
        uint256 investment = investmentAmountOf[investor];
        if (investment == 0) revert();
        investmentAmountOf[investor] = 0;
        investmentRefunded += investment;
        emit Refund(msg.sender, investment);
    
        if (!investor.send(investment)) revert();
    }    
}

contract TranchePricingCrowdsale is SimpleCrowdsale  {

    struct Tranche {
        uint256 weiHighLimit;
        uint256 weiTokenPrice;
    }
    
    mapping(uint256 => Tranche) public trancheStructure;
    uint256 public currentTrancheLevel;

    constructor(uint256 _startTime, uint256 _endTime, 
    	uint256 _etherInvestmentObjective) 
    	SimpleCrowdsale(_startTime, _endTime,
    	   1, _etherInvestmentObjective)
    	payable public
    {
        trancheStructure[0] = Tranche(3000 ether, 0.002 ether);
        trancheStructure[1] = Tranche(10000 ether, 0.003 ether);
        trancheStructure[2] = Tranche(15000 ether, 0.004 ether);
        trancheStructure[3] = Tranche(1000000000 ether, 0.005 ether);
        
        currentTrancheLevel = 0;
    } 
    
    function calculateNumberOfTokens(uint256 investment) 
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

contract UnlimitedFixedPricingCrowdsale is FixedPricingCrowdsale {
    
    constructor(uint256 _startTime, uint256 _endTime, 
    	uint256 _weiTokenPrice, uint256 _etherInvestmentObjective)
    	FixedPricingCrowdsale(_startTime, _endTime, 
    	_weiTokenPrice, _etherInvestmentObjective)
    	payable public  {
    }
    
    function createFundingLimitStrategy() 
        internal returns (FundingLimitStrategy) {
        
        return new UnlimitedFundingStrategy(); 
    }
}

contract CappedFixedPricingCrowdsale  is FixedPricingCrowdsale {
    
    constructor(uint256 _startTime, uint256 _endTime, 
    	uint256 _weiTokenPrice, uint256 _etherInvestmentObjective)
    	FixedPricingCrowdsale(_startTime, _endTime, 
    	_weiTokenPrice, _etherInvestmentObjective)
    	payable public  {
    }
    
    function createFundingLimitStrategy() 
        internal returns (FundingLimitStrategy) {
        
        return new CappedFundingStrategy(10000); 
    }
}

contract UnlimitedTranchePricingCrowdsale is TranchePricingCrowdsale {
    
    constructor(uint256 _startTime, uint256 _endTime, 
    	uint256 _etherInvestmentObjective)
    	TranchePricingCrowdsale(_startTime, _endTime, 
    	_etherInvestmentObjective)
    	payable public  {
    }
    
    function createFundingLimitStrategy() 
        internal returns (FundingLimitStrategy) {
        
        return new UnlimitedFundingStrategy(); 
    }
}

contract CappedTranchePricingCrowdsale is TranchePricingCrowdsale {
    
    constructor(uint256 _startTime, uint256 _endTime, 
    	uint256 _etherInvestmentObjective)
    	TranchePricingCrowdsale(_startTime, _endTime, 
    	_etherInvestmentObjective)
    	payable public  {
    }
    
    function createFundingLimitStrategy() 
        internal returns (FundingLimitStrategy) {
        
        return new CappedFundingStrategy(10000); 
    }
}