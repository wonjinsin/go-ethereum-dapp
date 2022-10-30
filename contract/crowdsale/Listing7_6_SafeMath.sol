pragma solidity ^0.4.24;

library SafeMath { //#A
    function mul(uint256 a, uint256 b)
        public pure returns (uint256) {//#B
        if (a == 0) return 0;

        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) 
        public pure returns (uint256) {//#B
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) 
        public pure returns (uint256) {//#B
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) 
        public pure returns (uint256) {//#B
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
/*
#A The library keyword is used instead of the contract keyword
#B Functions in a library are defined exactly as in contracts
#C Check on the input or on the result of the arithmetic operation 
*/