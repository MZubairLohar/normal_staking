// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.5.0;

import './IERC20.sol';

interface IRewardsDistributionRecipient {
    // function notifyRewardAmount(uint256 reward) external;
    function getRewardToken() external view returns (IERC20);
}