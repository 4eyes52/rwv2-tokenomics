# Realms World Tokenomics Design

Realms World is a decentralized gaming network designed to support hundreds or thousands of games, each with its own economy. The Realms World token (**$RW**) is the foundational asset that powers the ecosystem.

---

## 1. Overview

- **Project Name:** Realms World
- **Core Token:** $RW
- **Purpose:**
  - Serve as the underlying liquidity token for all game-specific tokens.
  - Facilitate decentralized exchange (DEX) liquidity and cross-game asset exchange.
  - Enable transaction fee settlements, staking rewards, and various in-game incentives.

---

## 2. Token Overview

- **Token Name:** $RealmsWorld (or an alternative name as desired)
- **Ticker:** RW
- **Token Type:** ERC-20 (compatible with StarkNet)
- **Utility:**
  - **Liquidity:** Used as a liquidity pair for game-specific tokens.
  - **Transaction Fees:** Serves as the medium for fee settlements across the network.
  - **Staking:** Provides rewards and security incentives.
  - **Governance:** May be used for voting on network or game-specific proposals.

---

## 3. Supply & Distribution

- **Supply Model:** Inflationary with Burns
- **Initial Circulating Supply:** 200,000,000 RW
- **Emission Schedule:**
  - **Dynamic Inflation:** Adjusted based on network activity.
  - **Per-Block Inflation:** Annualized at 5% via a per-block mechanism.
- **Burn Mechanism:**
  - **Adaptive Burn:** A percentage of tokens is burned during transfers.
  - **Oracle Integration:** The burn rate is updated dynamically by a designated oracle.
- **$LORDS Token Burn:**
  - **1:1 Burn-to-Mint:** Burning $LORDS tokens mints an equivalent amount of $RW.

---

## 4. Network Functionality & Token Utility

- **Game-Specific Tokens:**
  - Each game can launch its own ERC-20 token.
  - These tokens are bonded with $RW for liquidity and stability.
- **Demand Drivers:**
  - **DEX Usage:** $RW is required to swap between game tokens.
  - **Transaction Fees:** Fees generated within the ecosystem are paid in $RW.
  - **Cross-Game Economy:** $RW enables asset exchange across various games.

---

## 5. Inflation & Deflation Mechanics

### Inflationary Mechanisms

- **Dynamic Inflation (Per Block):**
  - The contract calculates additional token supply based on the number of blocks elapsed since the last inflation update.
  - **Formula:**

    \[
    \text{additional\_supply} = \frac{\text{current\_supply} \times \text{INFLATION\_RATE\_BP} \times \text{blocks\_elapsed}}{10000 \times \text{BLOCKS\_PER\_YEAR}}
    \]

- **Constants:**
  - **INFLATION_RATE_BP:** 500 (5% annual inflation in basis points)
  - **BLOCKS_PER_YEAR:** Set based on expected block frequency (e.g., 31,536,000 for 1 block per second)

### Deflationary Mechanisms

- **Adaptive Burn:**
  - A portion of tokens is burned during each transfer.
  - The burn rate is updated dynamically by a designated oracle based on off-chain network metrics.
- **DEX & Liquidity Fee Burns:**
  - Portions of fees from token swaps and liquidity operations are burned to help maintain scarcity.

---

## 6. Oracle Integration

- **Purpose:**
  - Automatically adjust key parameters (e.g., burn rate) based on real-world, off-chain metrics.
- **Mechanism:**
  - A designated `oracle_address` is set by the owner.
  - The oracle can call `update_burn_rate_from_oracle` to update the burn rate.
- **Security:**
  - Only the trusted oracle can update these parameters.

---

## 7. Staking & Rewards

- **Staking Functions:**
  - **Stake:** Users can lock $RW tokens to earn rewards.
  - **Unstake:** Withdraw staked tokens.
  - **Claim Rewards:** Accumulate and claim rewards based on staking duration and the defined reward rate.
- **Reward Calculation:**
  - Uses a constant (`REWARD_PRECISION`) to represent fractional rewards.
  - Rewards are accrued over time and calculated based on the staked amount and elapsed time.

---

## 8. LORDS Integration

- **1:1 Burn-to-Mint Mechanism:**
  - Users can burn $LORDS tokens via the `mint_from_lords` function.
  - The contract calls an external LORDS token contract’s `burn` function.
  - Upon successful burning, the same amount of $RW tokens is minted for the user.

---

## 9. Treasury Management

- **Ecosystem Grants:**
  - Allocate $RW tokens to promising games and projects.
- **Revenue Allocation:**
  - A portion (e.g., 30%) of network-wide transaction fees is allocated to the treasury for further development and ecosystem growth.

---

## 10. Sustainability & Long-Term Planning

- **Dynamic Emissions:**
  - Adjust inflation and token issuance based on network activity.
- **Interoperability:**
  - $RW serves as the liquidity pair for multiple game-specific tokens, ensuring cross-game functionality.
- **Decentralized Infrastructure:**
  - Supports fair, scalable, and community-governed gaming ecosystems.
 
