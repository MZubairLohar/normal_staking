pragma solidity ^0.5.0;
import './ReentrancyGuard.sol';
import './SafeMath.sol';
import './SafeERC20.sol';
import './IERC20.sol';

contract StakingTokenWrapper is ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // IERC20 public stakingToken;
   
    
    
    uint256 internal _totalSupply;
    mapping(address => uint256) private _balances;

    // constructor(address _stakingToken ) internal {
    //     stakingToken = IERC20(_stakingToken);
       
    // }

    function totalSupply()
        public
        view
        returns (uint256)
    {
        return _totalSupply;
    }

    function balanceOf(address _account)
        public
        view
        returns (uint256)
    {
        return _balances[_account];
    }

    function _stake(address _beneficiary, uint256 _amount)
        internal
        nonReentrant
    {
        _totalSupply = _totalSupply.add(_amount);
        _balances[_beneficiary] = _balances[_beneficiary].add(_amount);
        // stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

    function _withdraw(uint256 _amount)
        internal
        nonReentrant
    {
        _totalSupply = _totalSupply.sub(_amount);
        _balances[msg.sender] = _balances[msg.sender].sub(_amount);
        
        require(balanceOf(msg.sender) > 0, 'balance not enough');
        
        msg.sender.transfer(balanceOf(msg.sender));
        //  stakingToken.safeTransfer(msg.sender, _amount);
    }
}