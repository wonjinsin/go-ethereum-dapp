pragma solidity ^0.4.24;
interface ReleasableToken {
    function mint(address _beneficiary, uint256 _numberOfTokens) external;
    function release() external;
    function transfer(address _to, uint256 _amount) external;
}

//--
/*
contract ReleasableSimpleCoin is ReleasableToken {
    //...
}
//#A ReleasableSimpleCoin already implements ReleasableToken as it stands

contract ReleasableComplexCoin is ReleasableToken {
    //...
}
*/
