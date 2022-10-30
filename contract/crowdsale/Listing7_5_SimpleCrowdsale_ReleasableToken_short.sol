contract SimpleCrowdsale is Ownable {
    ...
    ReleasableToken  public crowdsaleToken; //#A    
    ...
    
    constructor(uint256 _startTime, uint256 _endTime, 
        uint256 _weiTokenPrice, uint256 _etherInvestmentObjective) 
        payable public {
        ...    
        crowdsaleToken = createToken();//#B
        ...
    } 
    
    ...
    
    function createToken() 
        internal returns (ReleasableToken) {
            return new ReleasableSimpleCoin(0); //#C
        }
        
    ...   
}
/*
#A now the crowdsale contract can be any token implementing ReleasableToken
#B the token contract is instantiated in a function that can be overriden 
#C the default implementation offered by the SimpleCrowdsale abstract contract still instantiates ReleasableSimpleCoin
*/