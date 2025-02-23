# **Realms World Tokenomics Design**

Realms World is a **decentralized gaming network** designed to support hundreds or thousands of games, each with its own economy. The **Realms World token ($RW)** serves as the foundational asset that powers the ecosystem.

---

## **1. Overview**
- **Project Name:** Realms World  
- **Core Token:** $RW  
- **Purpose:**  
  - Serve as the **underlying liquidity token** for all game-specific tokens.  
  - Facilitate **decentralized exchange (DEX) liquidity** and cross-game asset exchange.  
  - Enable **staking rewards, governance participation, and incentive distribution.**  

---

## **2. Token Overview**
- **Token Name:** $RealmsWorld  
- **Ticker:** RW  
- **Token Type:** ERC-20 (StarkNet compatible)  
- **Utility:**
  - **Liquidity:** Used as a liquidity pair for game-specific tokens.  
  - **Transaction Fees:** Medium for fee settlements across the network.  
  - **Staking:** Earn rewards by locking $RW tokens.  
  - **Governance:** May be used for **voting on network** or **game-specific proposals**.  

---

## **3. Supply & Distribution**
- **Supply Model:** Inflationary with Burns  
- **Initial Circulating Supply:** 200,000,000 RW  
- **Emission Schedule:**  
  - **Time-Based Inflation:** Adjusted based on elapsed time instead of block count.  
  - **Annualized Inflation Rate:** 5% per year, dynamically adjusted.  

### **Burn Mechanism**
- **Adaptive Burn:** A percentage of tokens is **burned during transfers**.  
- **Oracle Integration:** The **burn rate is updated dynamically** by a designated oracle.  
- **$LORDS Token Burn:**  
  - **1:1 Burn-to-Mint:** Burning **$LORDS tokens** mints an **equivalent amount of $RW**.  

---

## **4. Network Functionality & Token Utility**
### **Game-Specific Tokens**
- Each game can **launch its own ERC-20 token**.  
- These tokens are **bonded with $RW for liquidity and stability**.  

### **Demand Drivers**
- **DEX Usage:** $RW is required for swapping between game tokens.  
- **Transaction Fees:** Fees generated within the ecosystem are paid in $RW.  
- **Cross-Game Economy:** $RW facilitates **asset exchange across multiple games**.  

---

## **5. Inflation & Deflation Mechanics**
### **Inflationary Mechanisms**
- **Time-Based Inflation** (instead of block-based)  
- The contract calculates **additional token supply based on the elapsed time** since the last inflation update.

#### **Formula:**
additional_supply = (current_supply * INFLATION_RATE_BP * seconds_elapsed) / (10000 * SECONDS_PER_YEAR)
### **Example Calculation:**
- **Assume** `current_supply = 200,000,000 RW`  
- **Assume** `seconds_elapsed = 1,000,000`  
- **Assume** `SECONDS_PER_YEAR = 31,536,000`  
- **Since** `INFLATION_RATE_BP = 500`, we get:

additional_supply = (200,000,000 * 500 * 1,000,000) / (10000 * 31,536,000) additional_supply = (100,000,000,000) / (315,360,000,000) additional_supply ≈ 317 RW

**Thus, for every 1,000,000 seconds, approximately 317 RW tokens are minted** under the **5% annualized inflation model**.

### **Deflationary Mechanisms**
- **Adaptive Burn:**  
  - A **portion of tokens is burned** during each transfer.  
  - The **burn rate is dynamically adjusted** by a designated oracle.  
- **DEX & Liquidity Fee Burns:**  
  - A portion of fees from **token swaps and liquidity operations is burned**, reducing supply.  

---

## **6. Oracle Integration**
### **Purpose**
- The oracle **automatically adjusts key parameters** (e.g., burn rate) based on **off-chain data**.  

### **Mechanism**
- A **designated `oracle_address` is set by the owner**.  
- The oracle can call **`update_burn_rate_from_oracle`** to update the burn rate.  

### **Security**
- **Only a trusted oracle** can update these parameters.  
- The burn rate **cannot exceed the max/min predefined limits** (`0.1% - 5%`).  

---

## **7. Staking & Rewards**
### **Staking Functions**
- **Stake:** Users can **lock $RW tokens** to earn rewards.  
- **Unstake:** Users can **withdraw staked tokens** at any time.  
- **Claim Rewards:** Users can **claim accrued rewards** based on staking duration.  

### **Reward Calculation**
- Uses a constant (`REWARD_PRECISION`) to represent **fractional rewards**.  
- Rewards are **proportional to the staked amount** and the **time elapsed**.  
- **70% of newly minted tokens go to stakers** via the **staker reward pool**.  

---

## **8. $LORDS Integration**
### **1:1 Burn-to-Mint Mechanism**
- Users can **burn $LORDS tokens** via the `mint_from_lords` function.  
- The contract **calls an external $LORDS contract** to verify the burn.  
- Upon successful burning, the **same amount of $RW tokens is minted**.  

---

## **9. Treasury Management**
### **Ecosystem Grants**
- The **treasury can allocate $RW** to **promising games** built on Realms World.  

### **Revenue Allocation**
- A **portion of transaction fees (e.g., 30%)** is allocated to the **treasury** for development.  
- Builder incentives are **funded by inflation**, ensuring long-term sustainability.  

---

## **10. Sustainability & Long-Term Planning**
- **Dynamic Emissions:**  
  - **Adjusts inflation and token issuance** based on **network activity**.  
- **Interoperability:**  
  - $RW serves as the **liquidity pair for multiple game-specific tokens**.  
- **Decentralized Infrastructure:**  
  - Supports a **fair, scalable, and community-governed gaming ecosystem**.
