

## Overview

The **Realms World v2 Tokenomics contract** is an ERC-20–style token with advanced features to support dynamic tokenomics:

- **Time-Based Inflation Mechanism**  
  The contract mints new tokens at a **5% annualized inflation rate**, calculated based on **elapsed time rather than block count**, ensuring a controlled and predictable increase in supply.

- **Staking & Rewards**  
  Users can stake their **$RW** tokens to earn rewards. The contract provides functions to **stake, unstake, and claim rewards**, with **70%** of the newly minted tokens allocated to stakers.

- **Builder Incentives**  
  **30%** of the minted tokens are allocated to a **builder incentive pool**, rewarding developers contributing to the ecosystem.

- **Adaptive Burn Mechanism**  
  Transfers incur a **burn fee**, adjustable between **0.1% and 5%**, dynamically set by an **authorized oracle** based on network metrics.

- **Oracle Integration**  
  A **designated oracle** address can **update the burn rate** within predefined limits to maintain optimal tokenomics based on network activity.

- **$LORDS Burn-to-Mint Mechanism**  
  Users can burn **$LORDS** tokens to mint new **$RW** tokens, facilitating **initial distribution**.

---

## Contract Features

### **Time-Based Inflation**
The contract implements a **time-based inflation mechanism**, minting new tokens at a **5% annual rate**. The `apply_inflation` function calculates **additional supply based on the elapsed time** since the last inflation application, distributing **70% to stakers** and **30% to builders**.

### **Staking Mechanism**
Users can stake their **$RW** tokens to earn rewards:
- **Stake** → Lock a specified amount of $RW tokens to participate in the staking program.
- **Unstake** → Withdraw a specified amount of previously staked tokens.
- **Claim Rewards** → Retrieve accumulated rewards from the **staker reward pool**, ensuring claims **do not exceed the pool's balance**.

### **Adaptive Burn Mechanism**
Transfers of **$RW tokens incur a burn fee**, reducing the total supply.  
The **burn rate is dynamically adjustable** between **0.1% and 5%**, set by an **authorized oracle** to respond to network conditions.

### **Oracle Integration**
An **authorized oracle** can **update the burn rate** within predefined limits, allowing the system to **adapt to changing network metrics** while maintaining stability.

### **$LORDS Burn-to-Mint Mechanism**
To facilitate **initial distribution** and interoperability, users can **burn $LORDS tokens** to mint an equivalent amount of **$RW tokens**, promoting collaboration between ecosystems.

