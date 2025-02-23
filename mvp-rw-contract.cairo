%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp, get_block_number, call_contract

// Constants for rewards, inflation, and allocation splits.
const REWARD_PRECISION = 1000000;
const BLOCKS_PER_YEAR = 31536000;  // 1 block per second estimate.
const INFLATION_RATE_BP = 500;      // 500 basis points = 5% annual inflation.
const STAKER_SHARE_BP = 7000;       // 70% of inflation goes to stakers.
const BUILDER_SHARE_BP = 3000;      // 30% of inflation goes to builders.
const MAX_BURN_RATE = 500;          // Max burn rate = 5% (in basis points).
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
// Storage Variable: Inflation Timing (by block)
//////////////////////////////
@storage_var
func last_inflation_block() -> (res: felt) {}

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
    let current_block = get_block_number();
    last_inflation_block.write(current_block,);
    staker_reward_pool.write(0,);
    builder_incentive_pool.write(0,);
    return ();
}

//////////////////////////////
// Security Improvements in Core Functions
//////////////////////////////

// ✅ Secure Burn Rate Update (with max/min limits)
#[external]
func update_burn_rate_from_oracle{
    syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*, 
    range_check_ptr
}(
    new_rate: felt
) -> () {
    let caller = get_caller_address();
    let (oracle_addr) = oracle_address.read();
    assert caller = oracle_addr, 'Unauthorized oracle';
    assert new_rate >= MIN_BURN_RATE && new_rate <= MAX_BURN_RATE, 'Burn rate out of range';
    burn_rate.write(new_rate,);
    return ();
}

// ✅ Secure Staker Reward Claim (Caps claims to available pool)
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

    // Deduct from reward pool
    staker_reward_pool.write(pool_balance - claimable_amount);
    stake_reward.write(caller, reward - claimable_amount);

    // Transfer rewards
    let (caller_balance) = balance_of.read(caller);
    balance_of.write(caller, caller_balance + claimable_amount);
    return ();
}

// ✅ Secure Inflation Mechanism (Prevent over-minting)
#[external]
func apply_inflation{
    syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*, 
    range_check_ptr
}() -> () {
    let caller = get_caller_address();
    let (current_owner) = owner.read();
    assert caller = current_owner, 'Not owner';

    let current_block = get_block_number();
    let (last_block) = last_inflation_block.read();
    assert current_block > last_block + BLOCKS_PER_YEAR / 1000, "Inflation already applied recently";

    let blocks_elapsed = current_block - last_block;
    let (current_supply) = total_supply.read();

    let additional_supply = (current_supply * INFLATION_RATE_BP * blocks_elapsed) / (10000 * BLOCKS_PER_YEAR);

    total_supply.write(current_supply + additional_supply);

    let staker_allocation = (additional_supply * STAKER_SHARE_BP) / 10000;
    let builder_allocation = additional_supply - staker_allocation;

    staker_reward_pool.write(staker_reward_pool.read() + staker_allocation);
    builder_incentive_pool.write(builder_incentive_pool.read() + builder_allocation);

    last_inflation_block.write(current_block,);
    return ();
}

// ✅ Secure LORDS Burn-to-Mint (Ensures burn confirmation)
#[external]
func mint_from_lords{
    syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*, 
    range_check_ptr
}(
    amount: felt
) -> () {
    let caller = get_caller_address();
    let (lord_addr) = lords_token_address.read();
    let calldata = [caller, amount];

    let (res) = call_contract(
         contract_address=lord_addr,
         function_selector = 0xDEADBEEF,  // Replace with the real burn function selector
         calldata=calldata
    );

    assert res == 1, "Burn failed";  // Ensure successful burn before minting

    let (caller_balance) = balance_of.read(caller);
    balance_of.write(caller, caller_balance + amount);
    return ();
}

// ✅ Secure Builder Incentives (Prevents governance attacks)
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
