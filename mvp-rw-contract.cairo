%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp, get_block_number, call_contract

# Constants for inflation and rewards.
const REWARD_PRECISION = 1000000;
const BLOCKS_PER_YEAR = 31536000;  // Adjust as needed (e.g., if 1 block per second).
const INFLATION_RATE_BP = 500;      // 500 basis points = 5% annual inflation.

#############################
# Storage Variables: Token
#############################
@storage_var
func name() -> (res: felt) {}
@storage_var
func symbol() -> (res: felt) {}
@storage_var
func decimals() -> (res: felt) {}
@storage_var
func total_supply() -> (res: felt) {}
@storage_var
func balance_of(address: felt) -> (res: felt) {}
@storage_var
func owner() -> (res: felt) {}
@storage_var
func burn_rate() -> (res: felt) {}

#############################
# Storage Variables: Staking
#############################
@storage_var
func stake_balance(address: felt) -> (res: felt) {}
@storage_var
func stake_reward(address: felt) -> (res: felt) {}
@storage_var
func stake_last_update(address: felt) -> (res: felt) {}
@storage_var
func reward_rate() -> (res: felt) {}

#############################
# Storage Variables: Oracle Integration
#############################
@storage_var
func oracle_address() -> (res: felt) {}

#############################
# Storage Variables: LORDS Integration
#############################
@storage_var
func lords_token_address() -> (res: felt) {}

#############################
# Storage Variable: Inflation Timing (using block numbers)
#############################
@storage_var
func last_inflation_block() -> (res: felt) {}

#############################
# Initialization Function
#############################
#[external]
func initialize{
    syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*, 
    range_check_ptr
}(
    name_: felt, 
    symbol_: felt, 
    decimals_: felt, 
    initial_supply: felt, 
    owner_: felt, 
    reward_rate_: felt
) -> () {
    name.write(name_,);
    symbol.write(symbol_,);
    decimals.write(decimals_,);
    total_supply.write(initial_supply,);
    balance_of.write(owner_, initial_supply,);
    owner.write(owner_,);
    # Set a default burn rate in basis points (e.g., 50 = 0.5%).
    burn_rate.write(50,);
    # Set the staking reward rate.
    reward_rate.write(reward_rate_,);
    # Initialize the last inflation update using the current block number.
    let current_block = get_block_number();
    last_inflation_block.write(current_block,);
    return ();
}

#############################
# Token Functions
#############################
#[external]
func transfer{
    syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*, 
    range_check_ptr
}(
    recipient: felt, 
    amount: felt
) -> (success: felt) {
    let caller = get_caller_address();
    let (sender_balance) = balance_of.read(caller);
    # Ensure the sender has enough balance.
    assert sender_balance >= amount, 'Insufficient balance';
    # Read current burn rate (basis points, denominator = 10000).
    let (rate) = burn_rate.read();
    let burn_fee = (amount * rate) / 10000;
    let transfer_amount = amount - burn_fee;
    balance_of.write(caller, sender_balance - amount);
    let (recipient_balance) = balance_of.read(recipient);
    balance_of.write(recipient, recipient_balance + transfer_amount);
    let (current_supply) = total_supply.read();
    total_supply.write(current_supply - burn_fee);
    return (success=1);
}

#[external]
func mint{
    syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*, 
    range_check_ptr
}(
    recipient: felt, 
    amount: felt
) -> () {
    let caller = get_caller_address();
    let (current_owner) = owner.read();
    assert caller = current_owner, 'Not owner';
    let (current_supply) = total_supply.read();
    total_supply.write(current_supply + amount);
    let (recipient_balance) = balance_of.read(recipient);
    balance_of.write(recipient, recipient_balance + amount);
    return ();
}

#############################
# Oracle Integration Functions
#############################
#[external]
func set_oracle_address{
    syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*, 
    range_check_ptr
}(
    new_oracle: felt
) -> () {
    let caller = get_caller_address();
    let (current_owner) = owner.read();
    assert caller = current_owner, 'Not owner';
    oracle_address.write(new_oracle,);
    return ();
}

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
    burn_rate.write(new_rate,);
    return ();
}

#############################
# LORDS Integration Functions
#############################
#[external]
func set_lords_token_address{
    syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*, 
    range_check_ptr
}(
    new_address: felt
) -> () {
    let caller = get_caller_address();
    let (current_owner) = owner.read();
    assert caller = current_owner, 'Not owner';
    lords_token_address.write(new_address,);
    return ();
}

#[external]
func mint_from_lords{
    syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*, 
    range_check_ptr
}(
    amount: felt
) -> () {
    let caller = get_caller_address();
    # Retrieve the LORDS token contract address.
    let (lord_addr) = lords_token_address.read();
    # Prepare calldata for the LORDS token burn function.
    # Assuming the LORDS token's burn function takes (caller, amount) as parameters.
    alloc_locals;
    let calldata = [caller, amount];
    let (res) = call_contract(
         contract_address=lord_addr,
         function_selector = 0xDEADBEEF,  # Replace with actual burn function selector.
         calldata=calldata
    );
    # After burning LORDS tokens 1:1, mint the same amount of RW tokens to the caller.
    mint(recipient=caller, amount=amount);
    return ();
}

#############################
# Staking Functions
#############################
func update_reward{
    syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*, 
    range_check_ptr
}(
    user: felt, 
    current_time: felt
) -> () {
    let (last) = stake_last_update.read(user);
    if last == 0 {
        stake_last_update.write(user, current_time,);
        return ();
    }
    let delta = current_time - last;
    let (balance) = stake_balance.read(user);
    let (rate) = reward_rate.read();
    # additional_reward = (balance * delta * rate) / REWARD_PRECISION.
    let additional_reward = (balance * delta * rate) / REWARD_PRECISION;
    let (current_reward) = stake_reward.read(user);
    stake_reward.write(user, current_reward + additional_reward,);
    stake_last_update.write(user, current_time,);
    return ();
}

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
    update_reward(user=caller, current_time=current_time);
    let (caller_balance) = balance_of.read(caller);
    assert caller_balance >= amount, 'Insufficient balance to stake';
    balance_of.write(caller, caller_balance - amount);
    let (current_stake) = stake_balance.read(caller);
    stake_balance.write(caller, current_stake + amount);
    return ();
}

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
    update_reward(user=caller, current_time=current_time);
    let (staked) = stake_balance.read(caller);
    assert staked >= amount, 'Not enough staked balance';
    stake_balance.write(caller, staked - amount);
    let (caller_balance) = balance_of.read(caller);
    balance_of.write(caller, caller_balance + amount);
    return ();
}

#[external]
func claim_rewards{
    syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*, 
    range_check_ptr
}() -> () {
    let caller = get_caller_address();
    let current_time = get_block_timestamp();
    update_reward(user=caller, current_time=current_time);
    let (reward) = stake_reward.read(caller);
    stake_reward.write(caller, 0);
    let (current_supply) = total_supply.read();
    total_supply.write(current_supply + reward);
    let (caller_balance) = balance_of.read(caller);
    balance_of.write(caller, caller_balance + reward);
    return ();
}

#############################
# Inflation Function (5% annualized per block rate)
#############################
#[external]
func apply_inflation{
    syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*, 
    range_check_ptr
}() -> () {
    let caller = get_caller_address();
    let (current_owner) = owner.read();
    # Only the owner can trigger inflation.
    assert caller = current_owner, 'Not owner';
    let current_block = get_block_number();
    let (last_block) = last_inflation_block.read();
    if last_block == 0 {
        last_inflation_block.write(current_block,);
        return ();
    }
    let blocks_elapsed = current_block - last_block;
    let (current_supply) = total_supply.read();
    # additional_supply = (current_supply * INFLATION_RATE_BP * blocks_elapsed) / (10000 * BLOCKS_PER_YEAR)
    let additional_supply = (current_supply * INFLATION_RATE_BP * blocks_elapsed) / (10000 * BLOCKS_PER_YEAR);
    mint(recipient=current_owner, amount=additional_supply);
    last_inflation_block.write(current_block,);
    return ();
}
