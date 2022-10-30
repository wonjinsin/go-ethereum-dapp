pragma solidity ^0.4.18;

import "./Listing7_F_ReleasableToken_interface.sol";
import "./Listing7_G_ReleasableSimpleCoin_ReleasableToken_interface.sol";
import "./Listing6_4_Ownable.sol";
import "./Listing7_C_FundingLimitStrategy.sol";


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
    
    FundingLimitStrategy internal fundingLimitStrategy;//#A
    
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
        internal constant returns (bool) {
        bool nonZeroInvestment = _investment != 0;
        bool withinCrowdsalePeriod = now >= startTime && now <= endTime; 
    		
        return nonZeroInvestment && withinCrowdsalePeriod
           && fundingLimitStrategy.isFullInvestmentWithinLimit(_investment, investmentReceived);//#B
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