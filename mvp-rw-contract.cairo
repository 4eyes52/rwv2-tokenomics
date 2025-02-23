%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp, call_contract

// Constants
const REWARD_PRECISION = 1000000;
const SECONDS_PER_YEAR = 31536000;  // Standard year in seconds.
const INFLATION_RATE_BP = 500;      // 500 basis points = 5% annual inflation.
const STAKER_SHARE_BP = 7000;       // 70% of inflation to stakers.
const BUILDER_SHARE_BP = 3000;      // 30% to builders.
const MAX_BURN_RATE = 500;          // Max burn rate = 5%.
const MIN_BURN_RATE = 10;           // Min burn rate = 0.1%.

//////////////////////////////
// Storage Variables: Token
//////////////////////////////
@storage_var
func total_supply() -> (res: felt) {}
@storage_var
func balance_of(address: felt) -> (res: felt) {}
@storage_var
func owner() -> (res: felt) {}
@storage_var
func burn_rate() -> (res: felt) {}

//////////////////////////////
// Storage Variables: Staking
//////////////////////////////
@storage_var
func stake_balance(address: felt) -> (res: felt) {}
@storage_var
func stake_reward(address: felt) -> (res: felt) {}
@storage_var
func stake_last_update(address: felt) -> (res: felt) {}

//////////////////////////////
// Storage Variables: Oracle Integration
//////////////////////////////
@storage_var
func oracle_address() -> (res: felt) {}

//////////////////////////////
// Storage Variables: LORDS Integration
//////////////////////////////
@storage_var
func lords_token_address() -> (res: felt) {}

//////////////////////////////
// Storage Variables: Inflation Timing (Timestamp-Based)
//////////////////////////////
@storage_var
func last_inflation_timestamp() -> (res: felt) {}

//////////////////////////////
// Storage Variables: Reward Pools
//////////////////////////////
@storage_var
func staker_reward_pool() -> (res: felt) {}
@storage_var
func builder_incentive_pool() -> (res: felt) {}

//////////////////////////////
// Initialization Function
//////////////////////////////
#[external]
func initialize{
    syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*, 
    range_check_ptr
}(
    initial_supply: felt, 
    owner_: felt
) -> () {
    total_supply.write(initial_supply,);
    balance_of.write(owner_, initial_supply,);
    owner.write(owner_,);
    burn_rate.write(50,);  // Default burn rate: 0.5%.
    let current_time = get_block_timestamp();
    last_inflation_timestamp.write(current_time,);
    staker_reward_pool.write(0,);
    builder_incentive_pool.write(0,);
    return ();
}

//////////////////////////////
// Staking Functionality
//////////////////////////////

// ✅ Staking Tokens
#[external]
func stake{
    syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*, 
    range_check_ptr
}(
    amount: felt
) -> () {
    let caller = get_caller_address();
    let current_time = get_block_timestamp();

    // Ensure user has enough balance
    let (caller_balance) = balance_of.read(caller);
    assert caller_balance >= amount, 'Insufficient balance';

    // Update staker balance
    balance_of.write(caller, caller_balance - amount);
    let (current_stake) = stake_balance.read(caller);
    stake_balance.write(caller, current_stake + amount);

    // Update last reward update timestamp
    stake_last_update.write(caller, current_time);

    return ();
}

// ✅ Unstaking Tokens
#[external]
func unstake{
    syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*, 
    range_check_ptr
}(
    amount: felt
) -> () {
    let caller = get_caller_address();
    let current_time = get_block_timestamp();

    let (staked_amount) = stake_balance.read(caller);
    assert staked_amount >= amount, 'Not enough staked balance';

    // Deduct staked amount
    stake_balance.write(caller, staked_amount - amount);

    // Transfer unstaked amount back to balance
    let (caller_balance) = balance_of.read(caller);
    balance_of.write(caller, caller_balance + amount);

    // Update last update timestamp
    stake_last_update.write(caller, current_time);

    return ();
}

// ✅ Claim Staking Rewards
#[external]
func claim_rewards{
    syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*, 
    range_check_ptr
}() -> () {
    let caller = get_caller_address();
    let (reward) = stake_reward.read(caller);
    let (pool_balance) = staker_reward_pool.read();
    
    let claimable_amount = if reward > pool_balance { pool_balance } else { reward };

    staker_reward_pool.write(pool_balance - claimable_amount);
    stake_reward.write(caller, reward - claimable_amount);

    let (caller_balance) = balance_of.read(caller);
    balance_of.write(caller, caller_balance + claimable_amount);
    return ();
}

//////////////////////////////
// Secure Inflation Mechanism (Time-Based)
//////////////////////////////
#[external]
func apply_inflation{
    syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*, 
    range_check_ptr
}() -> () {
    let caller = get_caller_address();
    let (current_owner) = owner.read();
    assert caller = current_owner, 'Not owner';

    let current_time = get_block_timestamp();
    let (last_time) = last_inflation_timestamp.read();
    
    assert current_time > last_time + SECONDS_PER_YEAR / 100, "Inflation already applied recently";

    let (current_supply) = total_supply.read();
    let seconds_elapsed = current_time - last_time;

    let additional_supply = (current_supply * INFLATION_RATE_BP * seconds_elapsed) / (10000 * SECONDS_PER_YEAR);

    total_supply.write(current_supply + additional_supply);

    let staker_allocation = (additional_supply * STAKER_SHARE_BP) / 10000;
    let builder_allocation = additional_supply - staker_allocation;

    staker_reward_pool.write(staker_reward_pool.read() + staker_allocation);
    builder_incentive_pool.write(builder_incentive_pool.read() + builder_allocation);

    last_inflation_timestamp.write(current_time,);
    return ();
}

//////////////////////////////
// Secure Governance-Based Builder Incentives
//////////////////////////////
#[external]
func claim_builder_incentives{
    syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*, 
    range_check_ptr
}() -> () {
    let caller = get_caller_address();
    let (builder_funds) = builder_incentive_pool.read();

    assert builder_funds > 0, "No available builder incentives";

    builder_incentive_pool.write(0);
    let (caller_balance) = balance_of.read(caller);
    balance_of.write(caller, caller_balance + builder_funds);
    return ();
}
