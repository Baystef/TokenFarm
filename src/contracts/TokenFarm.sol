// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

import "./DappToken.sol";
import "./DaiToken.sol";

contract TokenFarm {
  string public name = "Dapp Token Farm";
  DappToken public dappToken;
  DaiToken public daiToken;
  address public owner;

  address[] public stakers;
  mapping(address => uint) public stakingBalance;
  mapping(address => bool) public hasStaked;
  mapping(address => bool) public isStaking;

  constructor(DappToken _dappToken, DaiToken _daiToken) public {
    dappToken = _dappToken;
    daiToken = _daiToken;
    owner = msg.sender;
  }

  modifier greaterThanZero(uint _amount) {
    require(_amount > 0, "amount cannot be 0");
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "caller must be owner");
    _;
  }

  // Stake Tokens (Deposit)
  function stakeTokens(uint _amount) public greaterThanZero(_amount) {
    // Transfer Mock Dai tokens to contract for staking
    daiToken.transferFrom(msg.sender, address(this), _amount);

    // Update staking balance
    stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

    // Add user to stakers array ONLY if they haven't staked already
    if (!hasStaked[msg.sender]) {
      stakers.push(msg.sender);
    }

    // Update staking status
    isStaking[msg.sender] = true;
    hasStaked[msg.sender] = true;
  }

  // Unstaking Tokens (Withdrawal
  function unstakeTokens() public {
    uint balance = stakingBalance[msg.sender];

    require(balance > 0, "staking balance cannot be 0");

    // Reset staking balance
    stakingBalance[msg.sender] = 0;

    // Transfer Mock Dai tokens back to investor
    daiToken.transfer(msg.sender, balance);

    //Update staking status
    isStaking[msg.sender] = false;

  }

  // Issuing Tokens
  function issueTokens() public onlyOwner {
    for (uint i = 0; i < stakers.length; i++) {
      address recipient = stakers[i];
      uint balance = stakingBalance[recipient];
      if (balance > 0) {    
        dappToken.transfer(recipient, balance);
      }     
    }
  }

}