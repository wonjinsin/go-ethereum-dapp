pragma solidity ^0.4.0;

contract SimpleCoin {
    mapping(address => uint256) public coinBalance;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public frozenAccount;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event FrozenAccount(address target, bool frozen);

    constructor(uint256 _initialSupply) public {
        owner = msg.sender;
        mint(owner, _initialSupply); // 최초 발행(Deploy)시 발행한 토큰을 컨트랙트 소유자에게
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert(); // 콘트랙트 소유자만 함수를 호출하도록 제한
        _;
    }

    function authorize(address _authorizedAccount, uint256 _allowance)
        public
        returns (bool success)
    {
        allowance[msg.sender][_authorizedAccount] = _allowance;
        return true;
    }

    // 이체 허용량 기능 구현
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool success) {
        require(_to != 0x0); // 기본값인 0x0 주소로 전송하는것을 방지
        require(coinBalance[_from] > _amount);
        require(coinBalance[_to] + _amount >= coinBalance[_to]); // 오버플로 방지
        require(_amount <= allowance[_from][msg.sender]);

        coinBalance[_from] -= _amount;
        coinBalance[_to] += _amount;
        allowance[_from][msg.sender] -= _amount;

        emit Transfer(_from, _to, _amount);
        return true;
    }

    function mint(address _recipient, uint256 _mintedAmount) public onlyOwner {
        coinBalance[_recipient] += _mintedAmount;
        emit Transfer(owner, _recipient, _mintedAmount);
    }

    function freezeAccount(address target, bool freeze) public onlyOwner {
        frozenAccount[target] = freeze;
        emit FrozenAccount(target, freeze);
    }

    function transfer(address _to, uint256 _amount) public {
        require(coinBalance[msg.sender] >= _amount);
        require(coinBalance[_to] + _amount >= coinBalance[_to]);
        coinBalance[msg.sender] -= _amount;
        coinBalance[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
    }
}
