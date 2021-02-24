const { assert } = require('chai');

require('chai').use(require('chai-as-promised')).should();

const StakingToken = artifacts.require('./StakingToken.sol');
const RewardToken = artifacts.require('./RewardToken.sol');
const NormalStaking = artifacts.require('./NormalStaking.sol');

function tokens(n) {
  return web3.utils.toWei(n, 'ether');
}

contract('NormalStaking', ([owner, investor]) => {
  let stakingToken, rewardToken, normalStaking;

  before(async () => {
    // Load Contracts
    stakingToken = await StakingToken.new();
    rewardToken = await RewardToken.new();
    normalStaking = await NormalStaking.new(
      stakingToken.address,
      rewardToken.address,
      owner,
      owner,
      owner
    );

    // Transfer all rewardToken Tokens to normal staking (1 million)
    await rewardToken.transfer(normalStaking.address, tokens('1000000'));

    // Send tokens to investor
    await stakingToken.transfer(investor, tokens('95'), { from: owner });
  });

  describe('stakingToken Deployment', async () => {
    it('has a name', async () => {
      const name = await stakingToken.name();
      assert.equal(name, 'Staking Token');
    });
  });

  describe('rewardToken Deployment', async () => {
    it('has a name', async () => {
      const name = await rewardToken.name();
      assert.equal(name, 'Reward Token');
    });
  });

  describe('normalStaking Deployment', async () => {
    it('contract has tokens', async () => {
      const balance = await rewardToken.balanceOf(normalStaking.address);
      assert.equal(balance.toString(), tokens('1000000'));
    });
  });

  describe('normalStaking Tokens', async () => {
    it('Investor is normalStaking stakingToken tokens for 1 block', async () => {
      let result, seconds;

      // Check investor balance before normalStaking
      result = await stakingToken.balanceOf(investor);
      assert.equal(
        result.toString(),
        tokens('95'),
        'Investor stakingToken balance before normalStaking'
      );

      // approve the normalStaking amount to normalStaking contract
      await stakingToken.approve(normalStaking.address, tokens('100'), {
        from: investor,
      });

      // Farm stakingToken tokens
      await normalStaking.stake(tokens('95'), { from: investor });

      // Check normalStaking status
      result = await stakingToken.balanceOf(investor);
      assert.equal(
        result.toString(),
        tokens('0'),
        'Investor stakingToken token balance correct before normalStaking 1'
      );

      result = await stakingToken.balanceOf(normalStaking.address);
      assert.equal(
        result.toString(),
        tokens('100'),
        'Investor stakingToken token balance correct before normalStaking 2'
      );

      result = await normalStaking.balanceOf(investor);
      assert.equal(
        result.toString(),
        tokens('100'),
        'Investor reward is correct after normalStaking'
      );

      // Check reward amount
      result = await normalStaking.RewardCalculator(investor);
      console.log(result.toString());
      // assert.equal(
      //   result.toString(),
      //   tokens('0.25'),
      //   'Investor reward is correct after normalStaking'
      // );

      // result = await normalStaking.stakeEnded(investor);
      // seconds = seconds + 300;
      // assert.equal(result.toString(), seconds, 'Investor normalStaking time');
    });
  });

  // describe('Unstaking tokens', () => {
  //   it('investor is unstaking and claiming rewards after 3 months', (done) => {
  //     setTimeout(async () => {
  //       let result;

  //       // Unfarm stakingToken tokens and get rewardToken tokens
  //       await normalStaking.unstake({ from: investor });

  //       // Check investor balance after normalStaking
  //       result = await stakingToken.balanceOf(investor);
  //       assert.equal(
  //         result.toString(),
  //         tokens('100'),
  //         'Investor stakingToken balance after normalStaking'
  //       );

  //       result = await rewardToken.balanceOf(investor);
  //       assert.equal(
  //         result.toString(),
  //         tokens('0.25'),
  //         'Investor rewardToken balance after normalStaking'
  //       );

  //       result = await normalStaking.stakeStarted(investor);
  //       assert.equal(
  //         result.toString(),
  //         0,
  //         'Investor normalStaking time after unstaking'
  //       );

  //       result = await normalStaking.stakeEnded(investor);
  //       assert.equal(
  //         result.toString(),
  //         0,
  //         'Investor normalStaking time after unstaking'
  //       );

  //       done();
  //     }, 60000);
  //   });
  // });

  // STAKING FOR 6 MONTHS
  // describe('normalStaking Tokens', async () => {
  //   it('Investor is normalStaking stakingToken tokens for 6 months', async () => {
  //     let result, seconds;

  //     // Check investor balance before normalStaking
  //     result = await stakingToken.balanceOf(investor);
  //     assert.equal(
  //       result.toString(),
  //       tokens('100'),
  //       'Investor stakingToken balance before normalStaking'
  //     );

  //     // approve the normalStaking amount to normalStaking contract
  //     await stakingToken.approve(normalStaking.address, tokens('100'), {
  //       from: investor,
  //     });

  //     // Farm stakingToken tokens
  //     await normalStaking.stake6m(tokens('10'), { from: investor });

  //     // // Checking timestamp
  //     // result = await normalStaking.stakeStarted(investor);
  //     // seconds = Math.floor(new Date().getTime() / 1000);
  //     // assert.equal(result.toString(), seconds, 'Investor normalStaking time');

  //     // Check normalStaking status
  //     result = await stakingToken.balanceOf(investor);
  //     assert.equal(
  //       result.toString(),
  //       tokens('90'),
  //       'Investor stakingToken token balance correct before normalStaking'
  //     );

  //     result = await stakingToken.balanceOf(normalStaking.address);
  //     assert.equal(
  //       result.toString(),
  //       tokens('10'),
  //       'Investor stakingToken token balance correct before normalStaking'
  //     );

  //     result = await normalStaking.balanceOf(investor);
  //     assert.equal(
  //       result.toString(),
  //       tokens('10'),
  //       'Investor reward is correct after normalStaking'
  //     );

  //     result = await normalStaking.tokensStaked(investor);
  //     assert.equal(
  //       result.toString(),
  //       tokens('10'),
  //       'Investor reward is correct after normalStaking'
  //     );

  //     // Check reward amount
  //     result = await normalStaking.earned(investor);
  //     assert.equal(
  //       result.toString(),
  //       tokens('0.75'),
  //       'Investor reward is correct after normalStaking'
  //     );

  //     // result = await normalStaking.stakeEnded(investor);
  //     // seconds = seconds + 300;
  //     // assert.equal(result.toString(), seconds, 'Investor normalStaking time');
  //   });
  // });

  // describe('Unstaking tokens', () => {
  //   it('investor is unstaking and claiming rewards after 6 months', (done) => {
  //     setTimeout(async () => {
  //       let result;

  //       // Unfarm stakingToken tokens and get rewardToken tokens
  //       await normalStaking.unstake({ from: investor });

  //       // Check investor balance after normalStaking
  //       result = await stakingToken.balanceOf(investor);
  //       assert.equal(
  //         result.toString(),
  //         tokens('100'),
  //         'Investor stakingToken balance after normalStaking'
  //       );

  //       result = await rewardToken.balanceOf(investor);
  //       assert.equal(
  //         result.toString(),
  //         tokens('1'),
  //         'Investor rewardToken balance after normalStaking'
  //       );

  //       result = await normalStaking.stakeStarted(investor);
  //       assert.equal(
  //         result.toString(),
  //         0,
  //         'Investor normalStaking time after unstaking'
  //       );

  //       result = await normalStaking.stakeEnded(investor);
  //       assert.equal(
  //         result.toString(),
  //         0,
  //         'Investor normalStaking time after unstaking'
  //       );

  //       done();
  //     }, 120000);
  //   });
  // });

  // STAKING FOR 12 MONTHS
  // describe('normalStaking Tokens', async () => {
  //   it('Investor is normalStaking stakingToken tokens for 12 months', async () => {
  //     let result, seconds;

  //     // Check investor balance before normalStaking
  //     result = await stakingToken.balanceOf(investor);
  //     assert.equal(
  //       result.toString(),
  //       tokens('100'),
  //       'Investor stakingToken balance before normalStaking'
  //     );

  //     // approve the normalStaking amount to normalStaking contract
  //     await stakingToken.approve(normalStaking.address, tokens('100'), {
  //       from: investor,
  //     });

  //     // Farm stakingToken tokens
  //     await normalStaking.stake12m(tokens('10'), { from: investor });

  //     // // Checking timestamp
  //     // result = await normalStaking.stakeStarted(investor);
  //     // seconds = Math.floor(new Date().getTime() / 1000);
  //     // assert.equal(result.toString(), seconds, 'Investor normalStaking time');

  //     // Check normalStaking status
  //     result = await stakingToken.balanceOf(investor);
  //     assert.equal(
  //       result.toString(),
  //       tokens('90'),
  //       'Investor stakingToken token balance correct before normalStaking'
  //     );

  //     result = await stakingToken.balanceOf(normalStaking.address);
  //     assert.equal(
  //       result.toString(),
  //       tokens('10'),
  //       'Investor stakingToken token balance correct before normalStaking'
  //     );

  //     result = await normalStaking.balanceOf(investor);
  //     assert.equal(
  //       result.toString(),
  //       tokens('10'),
  //       'Investor reward is correct after normalStaking'
  //     );

  //     result = await normalStaking.tokensStaked(investor);
  //     assert.equal(
  //       result.toString(),
  //       tokens('10'),
  //       'Investor reward is correct after normalStaking'
  //     );

  //     // Check reward amount
  //     result = await normalStaking.earned(investor);
  //     assert.equal(
  //       result.toString(),
  //       tokens('2.2'),
  //       'Investor reward is correct after normalStaking'
  //     );

  //     // result = await normalStaking.stakeEnded(investor);
  //     // seconds = seconds + 300;
  //     // assert.equal(result.toString(), seconds, 'Investor normalStaking time');
  //   });
  // });

  // describe('Unstaking tokens', () => {
  //   it('investor is unstaking and claiming rewards after 12 months', (done) => {
  //     setTimeout(async () => {
  //       let result;

  //       // Unfarm stakingToken tokens and get rewardToken tokens
  //       await normalStaking.unstake({ from: investor });

  //       // Check investor balance after normalStaking
  //       result = await stakingToken.balanceOf(investor);
  //       assert.equal(
  //         result.toString(),
  //         tokens('100'),
  //         'Investor stakingToken balance after normalStaking'
  //       );

  //       result = await rewardToken.balanceOf(investor);
  //       assert.equal(
  //         result.toString(),
  //         tokens('3.2'),
  //         'Investor rewardToken balance after normalStaking'
  //       );

  //       result = await normalStaking.stakeStarted(investor);
  //       assert.equal(
  //         result.toString(),
  //         0,
  //         'Investor normalStaking time after unstaking'
  //       );

  //       result = await normalStaking.stakeEnded(investor);
  //       assert.equal(
  //         result.toString(),
  //         0,
  //         'Investor normalStaking time after unstaking'
  //       );

  //       done();
  //     }, 180000);
  //   });
  // });
});
