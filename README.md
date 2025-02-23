# Realms World v2 Tokenomics

Realms World is a decentralized gaming network designed to support hundreds or thousands of games, each with its own economy. The Realms World token (**$RW**) is the foundational asset that powers the ecosystem. This repository contains the MVP smart contract implementation for Realms World tokenomics, written in Cairo 2.8.0 for deployment on StarkNet.

## Overview

The Realms World v2 Tokenomics contract implements an ERC-20–style token with several advanced features to support dynamic tokenomics, including:

- **Adaptive Burn Mechanism:**  
  Transfers incur a burn fee that is adjusted dynamically by an oracle based on off-chain metrics.
  
- **Per-Block Inflation:**  
  The contract mints new tokens based on a 5% annualized inflation rate calculated per block, ensuring a controlled increase in supply over time.
  
- **Staking & Rewards:**  
  Users can stake their $RW tokens to earn rewards. The contract provides functions to stake, unstake, and claim rewards based on staked amount and time.
  
- **Oracle Integration:**  
  A designated oracle address can update the burn rate to maintain optimal tokenomics based on network activity.
  
- **$LORDS Burn:**  
  Users  burn $LORDS tokens in a 1:1 burn-to-mint mechanism to receive new $RW tokens for initial token distribution.

## Key Features

- **Token Functionality:**  
  Standard ERC-20 token operations including transfer and mint functions with an integrated adaptive burn on transfers.
  
- **Inflation Mechanism:**  
  New tokens are minted based on the number of blocks elapsed since the last inflation update, following a 5% annual inflation rate.
  
- **Staking Module:**  
  Allows users to lock up $RW tokens, accrue rewards over time, and claim those rewards, enhancing network participation.
  
- **Oracle-Driven Adjustments:**  
  The burn rate can be dynamically updated by a trusted oracle to adapt to real-world network conditions.
  
- **Modular Design:**  
  Designed as an MVP with core tokenomics logic. Additional functionality (such as treasury management or cross-game token integrations) can be developed in separate modules.

## Repository Structure


## Getting Started

1. **Customization:**  
   Adjust configuration constants (such as `INFLATION_RATE_BP`, `BLOCKS_PER_YEAR`, and `REWARD_PRECISION`) to suit your network's parameters and desired tokenomics.

## Future Enhancements

- **Treasury Management:**  
  Implement additional logic for revenue allocation and ecosystem grants.
- **Advanced Fee Mechanisms:**  
  Integrate further deflationary measures and fee settlements across decentralized exchanges.
- **Cross-Game Tokenomics:**  
  Extend the model to support game-specific tokens and their interoperability with $RW.

---

This repository serves as a foundation for the Realms World ecosystem, providing a secure and efficient implementation of its core tokenomics on StarkNet.
