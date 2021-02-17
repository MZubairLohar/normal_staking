
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.5.0;
interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
library Address {

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}
contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {

        _notEntered = true;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}
contract StakingTokenWrapper is ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public stakingToken;
   
    
    
    uint256 internal _totalSupply;
    mapping(address => uint256) private _balances;

    constructor(address _stakingToken ) internal {
        stakingToken = IERC20(_stakingToken);
       
    }

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
        stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

    function _withdraw(uint256 _amount)
        internal
        nonReentrant
    {
        _totalSupply = _totalSupply.sub(_amount);
        _balances[msg.sender] = _balances[msg.sender].sub(_amount);
         stakingToken.safeTransfer(msg.sender, _amount);
        
       
    }
}
interface IRewardsDistributionRecipient {
    // function notifyRewardAmount(uint256 reward) external;
    function getRewardToken() external view returns (IERC20);
}
contract RewardsDistributionRecipient is IRewardsDistributionRecipient {

    // @abstract
    // function notifyRewardAmount(uint256 reward) external;
    function getRewardToken() external view returns (IERC20);

    // This address has the ability to distribute the rewards
    address public rewardsDistributor;

    /** @dev Recipient is a module, governed by mStable governance */
    constructor(address _rewardsDistributor) 
        internal
    {
        rewardsDistributor = _rewardsDistributor;
    }

    /**
     * @dev Only the rewards distributor can notify about rewards
     */
    modifier onlyRewardsDistributor() {
        require(msg.sender == rewardsDistributor, "Caller is not reward distributor");
        _;
    }
}
library StableMath {

    using SafeMath for uint256;

    uint256 private constant FULL_SCALE = 1e18;

    uint256 private constant RATIO_SCALE = 1e8;

    function getFullScale() internal pure returns (uint256) {
        return FULL_SCALE;
    }

    function getRatioScale() internal pure returns (uint256) {
        return RATIO_SCALE;
    }

    function scaleInteger(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return x.mul(FULL_SCALE);
    }

    function mulTruncate(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        return mulTruncateScale(x, y, FULL_SCALE);
    }

    function mulTruncateScale(uint256 x, uint256 y, uint256 scale)
        internal
        pure
        returns (uint256)
    {
        // e.g. assume scale = fullScale
        // z = 10e18 * 9e17 = 9e36
        uint256 z = x.mul(y);
        // return 9e38 / 1e18 = 9e18
        return z.div(scale);
    }

    function mulTruncateCeil(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        // e.g. 8e17 * 17268172638 = 138145381104e17
        uint256 scaled = x.mul(y);
        // e.g. 138145381104e17 + 9.99...e17 = 138145381113.99...e17
        uint256 ceil = scaled.add(FULL_SCALE.sub(1));
        // e.g. 13814538111.399...e18 / 1e18 = 13814538111
        return ceil.div(FULL_SCALE);
    }

    function divPrecisely(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        // e.g. 8e18 * 1e18 = 8e36
        uint256 z = x.mul(FULL_SCALE);
        // e.g. 8e36 / 10e18 = 8e17
        return z.div(y);
    }

    function mulRatioTruncate(uint256 x, uint256 ratio)
        internal
        pure
        returns (uint256 c)
    {
        return mulTruncateScale(x, ratio, RATIO_SCALE);
    }

    function mulRatioTruncateCeil(uint256 x, uint256 ratio)
        internal
        pure
        returns (uint256)
    {
        // e.g. How much mAsset should I burn for this bAsset (x)?
        // 1e18 * 1e8 = 1e26
        uint256 scaled = x.mul(ratio);
        // 1e26 + 9.99e7 = 100..00.999e8
        uint256 ceil = scaled.add(RATIO_SCALE.sub(1));
        // return 100..00.999e8 / 1e8 = 1e18
        return ceil.div(RATIO_SCALE);
    }

    function divRatioPrecisely(uint256 x, uint256 ratio)
        internal
        pure
        returns (uint256 c)
    {
        // e.g. 1e14 * 1e8 = 1e22
        uint256 y = x.mul(RATIO_SCALE);
        // return 1e22 / 1e12 = 1e10
        return y.div(ratio);
    }

    function min(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        return x > y ? y : x;
    }

    function max(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        return x > y ? x : y;
    }

    function clamp(uint256 x, uint256 upperBound)
        internal
        pure
        returns (uint256)
    {
        return x > upperBound ? upperBound : x;
    }
}

contract BLldToBldStake is StakingTokenWrapper, RewardsDistributionRecipient{

    // ***************************************************   
    // ****************** State Variables ****************    
    // ***************************************************      
    address payable owner;
    address payable BuyBurn;
    
    IERC20 public rewardsToken;
    uint256 constant internal oneDay  = 86400 ;
    uint256 minStakeAmount = 1 * 1e20 ;
    uint256 public totalStake = 1; 
    //     ************ percentages ***********
    uint256 internal Fee = 5e18; // 5%
    uint256 internal rewardPercent = 2e18; // 200%
    
    //****************** DAYS ********************
    uint256 public constant YEAR_DURATION   = 31557600 seconds;
   
    uint256 internal stakingDuration = 0;
    uint256 internal poolId = 1 ;
    uint256 internal ethManti = 1e18;
    
    uint256 contractBalance;
    uint256 lastRewardUpdate;
    Pool[] public poolArray;
    address[] rights;
    uint256[] poolCheckPonts;

// ********************************************    
// *************** EVENTS ********************
// ********************************************
  

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event claiming(uint rewardInContract);
    
// ********************************************    
// *************** CONSTRUCTOR ********************
// ********************************************
 
    constructor( 
            address _stakingToken,
            address _rewardsToken,
            address payable _rewardsDistributor
            ) public
             StakingTokenWrapper(_stakingToken)
            RewardsDistributionRecipient(_rewardsDistributor)
            {
             rewardsToken = IERC20(_rewardsToken);
             owner = _rewardsDistributor;
             BuyBurn = _rewardsDistributor;
    }
            
// ********************************************    
// *************** MODIFIERS ********************
// ********************************************
 
 
 
    modifier isAccount(address _account) {
        require(!Address.isContract(_account), "Only external owned accounts allowed");
        _;
    }
    modifier onlyOwner(){
        require(msg.sender == owner,'only owner can run this transaction');
        _;
    }


// ********************************************    
// *************** STRUCTS ********************
// ********************************************
    
    struct Staker {
        address user;
        uint256 userStakedTokens;
        uint256 stakeStarted;
        uint256 stakeEnded;
        uint256 lastUpdate; 
        uint256 reward;
        uint256 withdrawn; 
    }
    struct Pool {
        uint256 poolId;
        uint256 checkPoint;
        uint256 rewardTokenBalance;
    }

    
  
    struct stakerReward{
        uint paid;
        
    }

// ********************************************    
// *************** MAPPING ********************
// ********************************************

    mapping (address =>  Staker) public stakerInfo;
      
    mapping (address => uint256) public userRewardsPaid;
    
    mapping (address => mapping(uint256 => stakerReward)) rewardChecker;
      

// ********************************************    
// *************** POOL REWARD ********************
// ********************************************


  
    
    function newPoolAdded(uint256 _newPool) internal{
        lastRewardUpdate = lastRewardUpdate.add(_newPool);
    }
    
    function createPool(uint256 _amount) public  {
        Pool memory newPool = Pool( poolId , block.timestamp , _amount);
        poolArray.push(newPool);
        poolId = poolId.add(1);
        poolCheckPonts.push(newPool.checkPoint);
      //  distributPool(poolId);
    }
    // function distributPool(uint _poolId) internal{
    //     uint payToPayee;
    //     Pool storage disReward = poolArray[_poolId];
    //     payToPayee = payToPayee.add(disReward.rewardTokenBalance);
    //     emit claiming(payToPayee);
    // }
    
    function withdrawOwner() public onlyOwner() {
        owner.transfer(balanceOf(address(this)));
    }


// ********************************************    
// *************** ACTIONS ********************
// ********************************************
     
     
    function stake(uint256 _addAmount)
        // payable
        external
    {
       //1 
    //   uint256 amountDeducor = _addAmount; 
    //      // deduction of 5% fee
    //   uint256 _feePercantage = amountDeducor.mul(Fee);
    //   uint256 _feeAmount  = _feePercantage.div(1e20);
       
    //false   
    //   uint256 _amountPerShare1 = _feeAmount.div(2);
    //   uint256 _amountPerShare2 = _feeAmount.div(2);
       
        // // transfering 2.5% each to treasury(owner) & BuyBurn
        // stakingToken.transfer(owner, _amountPerShare1);
        // stakingToken.transfer(BuyBurn, _amountPerShare2);
       
       // Stake Amount 
       
       //owner.transfer(_feeAmount);
       
       //2
    //   stakingToken.transferFrom(msg.sender, owner, _feeAmount);
    //   _addAmount = _addAmount.sub(_feeAmount);
    //   totalStake = totalStake.add(_addAmount);
        __stake(msg.sender, _addAmount);
        rights.push(msg.sender);
    }
   
    
    function __stake(address _beneficiary, uint256 _addAmount)
        internal
        isAccount(_beneficiary)
    {
        require(
            _addAmount >= minStakeAmount, 
            "Invalid staking amount"
        );
       
        Staker storage stkIn = stakerInfo[msg.sender];
        stkIn.userStakedTokens = stkIn.userStakedTokens.add(_addAmount);
        uint256 returnPercent = stkIn.userStakedTokens.mul(rewardPercent);
        stkIn.reward = returnPercent.div(1e18);
        stkIn.stakeStarted = block.timestamp;
        stkIn.stakeEnded =  block.timestamp.add(YEAR_DURATION);
        
        
        if(stkIn.user == address(0)){
            stkIn.user = msg.sender;
            stkIn.lastUpdate = block.timestamp;
            stkIn.withdrawn = 0;    
            
        }else{
            stkIn.stakeStarted = block.timestamp;
            stkIn.lastUpdate = block.timestamp;
            
        }
        
        _stake(_beneficiary, _addAmount);

        emit Staked(_beneficiary, _addAmount);
    }

    function unstake() external  {
        
        
        for(uint i = 0 ; i < poolArray.length ; i++) {
            Staker storage stk = stakerInfo[msg.sender];
           // uint currentTime = block.timestamp;
            
           // if( currentTime < stk.stakeEnded  ){
                    // if(stk.stakeStarted >= poolArray[i].checkPoint) {
                        uint rewarded;
                        rewarded = rewarded.add(poolArray[i].checkPoint);
                        stakerReward storage stkRwd = rewardChecker[msg.sender][rewarded];     
                        // uint amtPercentage;
                        uint poolPercentage;
                        uint userToken;
                        uint rwdPercentage;
                        uint reward;
                        // if(stkRwd.paid != 1){
                            uint ust = stk.userStakedTokens ;
                            
                            //********************************
                            //************ ERROR *************
                            //********************************
                            
                            uint amtPercentage = (ust.div(totalStake));
                            poolPercentage = poolPercentage.add(amtPercentage.mul(1e20));
                           
                            // *********** token minted reward ************
                            userToken = userToken.add(stk.userStakedTokens);
                            rwdPercentage = rwdPercentage.add(poolPercentage.mul(userToken));
                            reward = reward.add(rwdPercentage.div(1e20));
                            emit claiming( amtPercentage );
                            //uint rewardPay =  totalStake.sub(1);
                            claimReward( reward );
                            poolArray[i].rewardTokenBalance = poolArray[i].rewardTokenBalance.sub(reward);
                            stkRwd.paid = 1 ;
                            
                        // }    
                            
                    // }
            // }
             if( block.timestamp >= stk.stakeEnded){
            stk.userStakedTokens = stk.userStakedTokens.mul(0);
            stk.stakeEnded = stk.stakeEnded.mul(0);
            stk.stakeStarted = stk.stakeStarted.mul(0);
            stk.lastUpdate = block.timestamp;
            
        }
        }
          
         
       
     }

     
    function _unstake(uint _reward) internal {
         
     
        claimReward(_reward );
        
    } 
    
    
     function withdraw(uint256 _amount) internal isAccount(msg.sender){
        require(_amount > 0, "Cannot withdraw 0");
        // require(
        //     block.timestamp >= stakerInfo[msg.sender].stakeEnded, 
        //     "Reward cannot be claimed before staking ends"
        // );
        
        _withdraw(_amount);
        Staker storage stk = stakerInfo[msg.sender];
        stk.lastUpdate = stk.lastUpdate.add(block.timestamp);
        stk.withdrawn = stk.withdrawn.add(_amount);
        _withdraw(_amount);
        emit Withdrawn(msg.sender, _amount);
    }

    function claimReward(uint256 amount) internal isAccount(msg.sender){
            Staker storage stkr = stakerInfo[msg.sender];
            rewardsToken.transfer(msg.sender, amount);
            stkr.withdrawn = stkr.withdrawn.add(amount); 
            emit RewardPaid(msg.sender, amount);
            
        
    }
    
    
 
    
    // ********************************************    
    // *************** GETS ********************
    // ********************************************
    
    // View function to see pending Reward on frontend.
    function pendingReward(address _user) external view returns (uint256) {
        uint rewardCalculation;
        uint startTime;
        //uint endTime;
        Staker storage stk = stakerInfo[_user];
        rewardCalculation = stk.reward;
        startTime = stk.stakeStarted;
        uint Lastwithdraw = stk.withdrawn;
        //uint timeCompleted = startTime.sub(block.timestamp);
        uint rewardMul = stk.reward.mul(ethManti); 
        uint rewardPer = rewardMul.div(YEAR_DURATION);
        uint rewardPerSec = rewardPer.div(ethManti).add(1);
        uint remainingReward = rewardPerSec.sub(Lastwithdraw);
        return(remainingReward);
        
    }

    function getRewardToken() external view returns (IERC20){
        return rewardsToken;
    }

    function earned(address _account) external view returns (uint256) {
        Staker storage stkr = stakerInfo[_account];
        return stkr.withdrawn;
    }
    
    

    function tokensStaked(address _account) external view returns (uint256){
        Staker storage stkr = stakerInfo[_account];
        return stkr.userStakedTokens;
    }

    // ********************************************    
    // *************** ADMIN ********************
    // ********************************************

    function sendRewardTokens(uint256 _amount) public onlyRewardsDistributor {
        require(rewardsToken.transferFrom(msg.sender, address(this), _amount), "Transfering not approved!");
    }
    
    function withdrawRewardTokens(address receiver, uint256 _amount)  public onlyRewardsDistributor{
       
        require(rewardsToken.transfer(receiver, _amount), "Not enough tokens on contract!");
        
        
    }
    
    function withdrawStakeTokens(address receiver, uint256 _amount) public onlyRewardsDistributor{
        require(stakingToken.transfer(receiver, _amount), "Not enough tokens on contract!");
        
    }
    
}