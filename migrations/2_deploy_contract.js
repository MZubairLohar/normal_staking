const StakingToken = artifacts.require('./StakingToken.sol');
const RewardToken = artifacts.require('./RewardToken.sol');
const NormalStaking = artifacts.require('./NormalStaking.sol');

function tokens(n) {
  return web3.utils.toWei(n, 'ether');
}

module.exports = async function (deployer, _network, accounts) {
  // Deploy staking token
  await deployer.deploy(StakingToken);
  const stakingToken = await StakingToken.deployed();

  // Deploy reward token
  await deployer.deploy(RewardToken);
  const rewardToken = await RewardToken.deployed();

  // Deploy Normal Staking
  await deployer.deploy(
    NormalStaking,
    stakingToken.address,
    rewardToken.address,
    accounts[0],
    accounts[0],
    accounts[0]
  );
  const normalStaking = await NormalStaking.deployed();

  // Transfer all reward tokens to Farming (1 million)
  await rewardToken.transfer(normalStaking.address, tokens('1000000'), {
    from: accounts[0],
  });

  // Transfer 100 staking tokens to an accounts[1]
  await stakingToken.transfer(accounts[1], tokens('100'), {
    from: accounts[0],
  });
};
